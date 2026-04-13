# Documentación del Turista

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
