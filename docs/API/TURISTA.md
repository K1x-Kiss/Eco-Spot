# Documentación del Turista

## Obtener Elementos por Categoría

Obtiene elementos (rentals, negocios o experiencias) según la categoría especificada, filtrados por la ciudad y país del usuario autenticado.

**URL:** `GET /api/v1/tourist/items`

**Encabezados:**
| Campo | Valor |
|-------|-------|
| Authorization | Bearer {TOKEN_JWT} |

**Parámetros:**
| Campo | Tipo | Obligatorio | Descripción |
|-------|------|-------------|-------------|
| category | String | Sí | Categoría: RENTAL, EXPERIENCE o BUSINESS |

**Respuestas:**
- **200 OK:** Elementos encontrados
- **401 Unauthorized:** Token inválido o usuario no encontrado

**Ejemplo de solicitud:**
```bash
curl -X GET "http://localhost:8080/api/v1/tourist/items?category=RENTAL" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

**Nota:** La ciudad y país se obtienen automáticamente del perfil del usuario autenticado (campos `current_city` y `current_country`).
