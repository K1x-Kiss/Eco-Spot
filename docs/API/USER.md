# Documentación de Usuario

## Obtener Usuario Actual

Obtiene la información del usuario autenticado actualmente.

**URL:** `GET /api/v1/users/me`

**Encabezados:**
| Campo | Valor |
|-------|-------|
| Authorization | Bearer {TOKEN_JWT} |

**Respuestas:**
- **200 OK:** Usuario encontrado
- **400 Bad Request:** Token no proporcionado
- **401 Unauthorized:** Token inválido

**Ejemplo de solicitud:**
```bash
curl -X GET "http://localhost:8080/api/v1/users/me" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

**Estructura de respuesta:**
```json
{
  "id": "uuid",
  "name": "Test",
  "surname": "User",
  "email": "test@example.com",
  "currentCity": "Madrid",
  "currentCountry": "ESPAÑA",
  "rol": "TOURIST"
}
```

**Nota:** Este endpoint funciona para cualquier usuario autenticado (TOURIST o BUSINESS).

## Actualizar Ubicación

Actualiza la ciudad y país del usuario autenticado.

**URL:** `PATCH /api/v1/users/location`

**Encabezados:**
| Campo | Valor |
|-------|-------|
| Authorization | Bearer {TOKEN_JWT} |
| Content-Type | application/json |

**Cuerpo de la solicitud:**
| Campo | Tipo | Obligatorio | Descripción |
|-------|------|-------------|-------------|
| city | String | Sí | Nueva ciudad |
| country | String | Sí | Nuevo país |

**Respuestas:**
- **200 OK:** Ubicación actualizada exitosamente
- **400 Bad Request:** Datos faltantes o inválidos
- **401 Unauthorized:** Token inválido

**Ejemplo de solicitud:**
```bash
curl -X PATCH "http://localhost:8080/api/v1/users/location" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -H "Content-Type: application/json" \
  -d '{"city": "Barcelona", "country": "ESPAÑA"}'
```

**Nota:** Este endpoint funciona para cualquier usuario autenticado (TOURIST o BUSINESS).