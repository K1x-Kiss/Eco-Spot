# Documentación del Turista

## Crear Reserva

Crea una nueva reservación para un rental.

**URL:** `POST /api/v1/tourist/rentals/{rentalId}/reservations`

**Encabezados:**
| Campo | Valor |
|-------|-------|
| Authorization | Bearer {TOKEN_JWT} |

**Parámetros de ruta:**
| Campo | Tipo | Descripción |
|-------|------|-------------|
| rentalId | UUID | ID del rental |

**Cuerpo de la solicitud:**
| Campo | Tipo | Descripción |
|-------|------|-------------|
| startingDate | Date | Fecha de inicio (YYYY-MM-DD) |
| endDate | Date | Fecha de fin (YYYY-MM-DD) |

**Respuestas:**
- **201 Created:** Reservación creada
- **400 Bad Request:** Authorization faltante o fechas inválidas
- **403 Forbidden:** Fechas superpuestas con otra reservación o rental no disponible

**Ejemplo de solicitud:**
```bash
curl -X POST "http://localhost:8080/api/v1/tourist/rentals/550e8400-e29b-41d4-a716-446655440000/reservations" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -H "Content-Type: application/json" \
  -d '{"startingDate": "2026-05-01", "endDate": "2026-05-05"}'
```

**Notas:**
- Las reservaciones son por días (no por horas)
- Las fechas deben ser futuras
- No se pueden crear reservaciones con fechas que superen otras reservaciones existentes
- El host del rental puede cancelar la reservación posteriormente

## Crear Reseña

Crea una reseña para un rental donde el turista ha completado una estancia.

**URL:** `POST /api/v1/tourist/rentals/{rentalId}/reviews`

**Encabezados:**
| Campo | Valor |
|-------|-------|
| Authorization | Bearer {TOKEN_JWT} |

**Parámetros de ruta:**
| Campo | Tipo | Descripción |
|-------|------|-------------|
| rentalId | UUID | ID del rental |

**Cuerpo de la solicitud:**
| Campo | Tipo | Obligatorio | Descripción |
|-------|------|-------------|-------------|
| qualification | Integer | Sí | Calificación (1-5) |
| opinion | String | No | Opinion/opinión |

**Respuestas:**
- **201 Created:** Reseña creada exitosamente
- **400 Bad Request:** Authorization faltante o datos inválidos
- **403 Forbidden:** Usuario no tiene reservación pasada, ya reseñó, o calificación inválida

**Ejemplo de solicitud:**
```bash
curl -X POST "http://localhost:8080/api/v1/tourist/rentals/550e8400-e29b-41d4-a716-446655440000/reviews" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -H "Content-Type: application/json" \
  -d '{"qualification": 5, "opinion": "Great stay!"}'
```

**Notas:**
- El turista debe haber completado una estancia (reservación pasada) en el rental
- Solo se puede reseñar una vez por rental
- La calificación debe ser entre 1 y 5

## Cancelar Reserva

Cancela una reservación existente. Solo el turistas que hizo la reservación puede cancelarla.

**URL:** `PATCH /api/v1/host/reservations/{reservationId}/cancel`

**Encabezados:**
| Campo | Valor |
|-------|-------|
| Authorization | Bearer {TOKEN_JWT} |

**Parámetros de ruta:**
| Campo | Tipo | Descripción |
|-------|------|-------------|
| reservationId | UUID | ID de la reservación |

**Respuestas:**
- **200 OK:** Reservación cancelada exitosamente
- **400 Bad Request:** Encabezado Authorization faltante
- **403 Forbidden:** No autorizado o reservación ya cancelada

**Ejemplo de solicitud:**
```bash
curl -X PATCH "http://localhost:8080/api/v1/host/reservations/550e8400-e29b-41d4-a716-446655440000/cancel" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

**Notas:**
- Solo el turista que hizo la reservación puede cancelarla
- El host del rental o un ADMIN también pueden cancelar la reservación
- No se puede cancelar una reservación que ya está cancelada
- Las reservaciones canceladas no aparecen en las listas de reservaciones

## Obtener Elementos por Ubicación

Obtiene todos los elementos (rentals, negocios y experiencias) filtrados por la ciudad y país del usuario autenticado.

**URL:** `GET /api/v1/tourist/items`

**Encabezados:**
| Campo | Valor |
|-------|-------|
| Authorization | Bearer {TOKEN_JWT} |

**Respuestas:**
- **200 OK:** Elementos encontrados
- **400 Bad Request:** Token no proporcionado
- **401 Unauthorized:** Token inválido o usuario no encontrado

**Ejemplo de solicitud:**
```bash
curl -X GET "http://localhost:8080/api/v1/tourist/items" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

**Estructura de respuesta:**
```json
{
  "experiences": [
    { "id": "...", "name": "...", "city": "...", "country": "...", ... }
  ],
  "rentals": [
    { "id": "...", "name": "...", "city": "...", "country": "...", ... }
  ],
  "businesses": [
    { "id": "...", "name": "...", "city": "...", "country": "...", ... }
  ]
}
```

**Nota:** 
- La ciudad y país se obtienen automáticamente del perfil del usuario autenticado (campos `current_city` y `current_country`).
- Cada lista contiene un máximo de 10 elementos.

## Buscar Elementos

Busca elementos por nombre. Opcionalmente filtra por categoría.

**URL:** `GET /api/v1/tourist/search`

**Encabezados:**
| Campo | Valor |
|-------|-------|
| Authorization | Bearer {TOKEN_JWT} |

**Parámetros:**
| Campo | Tipo | Obligatorio | Descripción |
|-------|------|-------------|-------------|
| searchBy | String | Sí | Término de búsqueda (busca en nombres) |
| category | String | No | Categoría: RENTAL, BUSINESS o EXPERIENCE. Si se omite, busca en todas |

**Respuestas:**
- **200 OK:** Elementos encontrados
- **400 Bad Request:** searchBy faltante o categoría inválida
- **401 Unauthorized:** Token inválido

**Ejemplo de solicitud (todas las categorías):**
```bash
curl -X GET "http://localhost:8080/api/v1/tourist/search?searchBy=beach" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

**Ejemplo de solicitud (con categoría):**
```bash
curl -X GET "http://localhost:8080/api/v1/tourist/search?category=RENTAL&searchBy=beach" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

**Nota:** Los resultados se ordenan prioritizando los elementos del país del usuario autenticado.

## Obtener Reservaciones del Usuario

Obtiene las reservaciones del usuario autenticado, filtradas por upcoming (próximas o pasadas).

**URL:** `GET /api/v1/tourist/reservations`

**Encabezados:**
| Campo | Valor |
|-------|-------|
| Authorization | Bearer {TOKEN_JWT} |

**Parámetros:**
| Campo | Tipo | Obligatorio | Descripción |
|-------|------|-------------|-------------|
| upcoming | Boolean | No | `true` para reservaciones futuras, `false` para pasadas. Por defecto `true` |

**Respuestas:**
- **200 OK:** Reservaciones encontradas
- **400 Bad Request:** Token no proporcionado
- **401 Unauthorized:** Token inválido

**Ejemplo de solicitud (próximas):**
```bash
curl -X GET "http://localhost:8080/api/v1/tourist/reservations?upcoming=true" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

**Ejemplo de solicitud (pasadas):**
```bash
curl -X GET "http://localhost:8080/api/v1/tourist/reservations?upcoming=false" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

**Estructura de respuesta:**
```json
[
  {
    "id": "...",
    "name": "...",
    "description": "...",
    "contact": "...",
    "size": 100,
    "peopleQuantity": 4,
    "rooms": 2,
    "bathrooms": 1,
    "city": "Madrid",
    "country": "ESPAÑA",
    "location": "...",
    "valueNight": 150.0,
    "enable": true,
    "reviewAverage": 4.5,
    "images": [
      { "id": "...", "extension": ".jpg" }
    ]
  }
]
```

**Nota:** 
- Cada elemento en la respuesta es un `RentalResponse` con los detalles completos del rental.
- Se devuelven los rentals únicos de las reservaciones (sin duplicados si el usuario tiene múltiples reservaciones en el mismo rental).
