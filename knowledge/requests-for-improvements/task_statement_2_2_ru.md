# Task Statement 2.2: Реализация структурированных ответов об ошибках для MCP-инструментов

## Исходное задание (оригинал, для справки)

Task Statement 2.2: Implement structured error responses for MCP tools

Knowledge of:
- The MCP isError flag pattern for communicating tool failures back to the agent
- The distinction between transient errors (timeouts, service unavailability), validation errors (invalid input), business errors (policy violations), and permission errors
- Why uniform error responses (generic "Operation failed") prevent the agent from making appropriate recovery decisions
- The difference between retryable and non-retryable errors, and how returning structured metadata prevents wasted retry attempts

Skills in:
- Returning structured error metadata including errorCategory (transient/validation/permission), isRetryable boolean, and human-readable descriptions
- Including retriable: false flags and customer-friendly explanations for business rule violations so the agent can communicate appropriately
- Implementing local error recovery within subagents for transient failures, propagating to the coordinator only errors that cannot be resolved locally along with partial results and what was attempted
- Distinguishing between access failures (needing retry decisions) and valid empty results (representing successful queries with no matches)

---

## Зачем нужны структурированные ответы об ошибках

Агент, получивший только `"Operation failed"`, находится в информационном вакууме. Он не знает:

- можно ли повторить запрос,
- нужно ли передать управление координатору,
- что сообщить пользователю.

Структурированный ответ об ошибке -- это не просто диагностика для разработчика. Это управляющие данные для агента.

---

## Паттерн isError в MCP

В протоколе MCP инструмент возвращает объект с полем `isError: true`, когда выполнение завершилось неудачей. Это принципиально отличается от пустого результата (успешный запрос без совпадений).

Декларативная структура успешного пустого результата vs ошибки:

```
Успешный запрос, нет совпадений:
  isError: false
  content: []
  message: "No orders found for customer ID 4821"

Ошибка доступа:
  isError: true
  errorCategory: "transient"
  isRetryable: true
  message: "Payment service unavailable"
```

Агент обязан различать эти два случая. Пустой результат -- валидный ответ на вопрос. Ошибка -- сигнал к принятию решения о восстановлении.

---

## Таксономия ошибок

Четыре категории ошибок требуют разных стратегий восстановления:

```
transient   -- сервис недоступен, таймаут, сетевой сбой
              isRetryable: true
              стратегия: повторить локально, экспоненциальная задержка

validation  -- неверный формат входных данных, отсутствует обязательное поле
              isRetryable: false
              стратегия: исправить входные данные, не повторять запрос

business    -- нарушение бизнес-правила (сумма превышает лимит, запрет политикой)
              isRetryable: false
              стратегия: эскалировать, уведомить пользователя, не повторять

permission  -- недостаточно прав, токен истёк
              isRetryable: false (или true после обновления токена)
              стратегия: запросить авторизацию или эскалировать
```

---

## Структура ответа об ошибке

Минимальная структура, которую должен возвращать каждый MCP-инструмент при сбое:

```
{
  isError: true,
  errorCategory: "transient" | "validation" | "business" | "permission",
  isRetryable: boolean,
  errorCode: string,          // машиночитаемый идентификатор
  message: string,            // для агента: техническое описание
  customerMessage: string,    // для пользователя: вежливое объяснение
  attemptedOperation: string, // что именно пытался выполнить инструмент
  partialResults: any | null  // результаты, полученные до сбоя
}
```

---

## Реализация на Node.js

Обработчик MCP-инструмента с четырьмя типами ошибок:

```js
async function processRefund({ customerId, orderId, amount }) {
  // validation error -- не повторять
  if (!customerId || !orderId) {
    return {
      isError: true,
      errorCategory: "validation",
      isRetryable: false,
      errorCode: "MISSING_REQUIRED_FIELDS",
      message: "customerId and orderId are required",
      customerMessage: "We need your order information to process this refund.",
      attemptedOperation: "processRefund",
      partialResults: null,
    };
  }

  // business error -- не повторять, эскалировать
  if (amount > 500) {
    return {
      isError: true,
      errorCategory: "business",
      isRetryable: false,
      errorCode: "REFUND_LIMIT_EXCEEDED",
      message: `Refund amount ${amount} exceeds policy limit of 500`,
      customerMessage:
        "Refunds over $500 require supervisor approval. I'm connecting you with a specialist.",
      attemptedOperation: "processRefund",
      partialResults: null,
    };
  }

  try {
    const result = await paymentService.refund({ customerId, orderId, amount });
    return { isError: false, content: result };
  } catch (err) {
    // transient error -- можно повторить
    if (err.code === "SERVICE_UNAVAILABLE" || err.code === "TIMEOUT") {
      return {
        isError: true,
        errorCategory: "transient",
        isRetryable: true,
        errorCode: err.code,
        message: `Payment service unavailable: ${err.message}`,
        customerMessage: "We're experiencing a brief delay. Please wait a moment.",
        attemptedOperation: "processRefund",
        partialResults: null,
      };
    }

    // permission error
    if (err.code === "UNAUTHORIZED") {
      return {
        isError: true,
        errorCategory: "permission",
        isRetryable: false,
        errorCode: "UNAUTHORIZED",
        message: "Agent lacks permission to process refunds for this account tier",
        customerMessage: "I need to transfer you to someone with the right access.",
        attemptedOperation: "processRefund",
        partialResults: null,
      };
    }

    throw err; // неожиданная ошибка -- пробрасываем выше
  }
}
```

---

## Локальное восстановление в субагенте

Субагент должен самостоятельно обрабатывать transient-ошибки и передавать координатору только то, что не может разрешить локально.

```
Субагент:
  1. Получает transient-ошибку
  2. Повторяет до 3 раз с задержкой (100ms, 300ms, 900ms)
  3. Если все попытки неудачны:
     передаёт координатору:
       - partialResults (что удалось собрать)
       - attemptedOperation (что пытался сделать)
       - finalError (последний ответ об ошибке)

  Validation / business / permission ошибки:
     передаёт координатору немедленно, без повторных попыток
```

Координатор принимает решение об эскалации или использовании partialResults для частичного ответа.

---

## Различие: ошибка доступа vs пустой результат

Это самое важное разграничение для корректного поведения агента:

```
get_orders({ customerId: "C001" })

Случай A -- заказов нет (успех):
  isError: false
  content: []
  message: "Customer C001 has no orders"
  --> агент сообщает: "У вас нет заказов"

Случай B -- сервис недоступен (ошибка):
  isError: true
  errorCategory: "transient"
  isRetryable: true
  message: "Order service timeout after 5000ms"
  --> агент повторяет запрос или сообщает о временной недоступности
```

Если агент не различает эти случаи, он сообщит пользователю об отсутствии заказов в ситуации, когда данные просто недоступны -- это критическая ошибка поведения.

---

## Ключевые принципы для экзамена

- `isError: true` всегда сопровождается `errorCategory` и `isRetryable` -- без этих полей ответ считается неполным
- `isRetryable: false` у business-ошибок предотвращает бесполезные повторные попытки
- `customerMessage` -- отдельное поле, не техническое сообщение об ошибке; агент использует его напрямую в ответе пользователю
- `partialResults` позволяет координатору принять частичное решение вместо полного отказа
- Пустой массив результатов при `isError: false` -- это не ошибка, это ответ
