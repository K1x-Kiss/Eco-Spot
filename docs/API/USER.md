# Documentación de Usuario

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