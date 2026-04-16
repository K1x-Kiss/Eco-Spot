# Documentación de Negocios

## Crear Negocio

Crea un nuevo negocio (business) asociado al usuario HOST autenticado.

**URL:** `POST /api/v1/businesses`

**Encabezados:**
| Campo | Valor |
|-------|-------|
| Authorization | Bearer {TOKEN_JWT} |

**Cuerpo de la solicitud (JSON):**
| Campo | Tipo | Obligatorio | Descripción |
|-------|------|-------------|-------------|
| name | String | Sí | Nombre del negocio |
| description | String | No | Descripción del negocio |
| contact | String | Sí | Teléfono de contacto |
| city | String | Sí | Ciudad |
| country | String | Sí | País |
| location | String | No | Dirección/ubicación |
| menu | String | No | Menú del negocio (para restaurantes) |

**Imágenes (multipart/form-data):**
| Campo | Tipo | Obligatorio | Descripción |
|-------|------|-------------|-------------|
| images | File[] | No | Imágenes (máximo 3, formatos: jpg, png, webp) |

**Respuestas:**
- **201 Created:** Negocio creado exitosamente
- **400 Bad Request:** Datos faltantes, inválidos o más de 3 imágenes
- **401 Unauthorized:** Token inválido o usuario no tiene rol BUSINESS

**Ejemplo de solicitud:**
```bash
curl -X POST "http://localhost:8080/api/v1/businesses" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Restaurante Mi Casa",
    "description": "Restaurant de comida tradicional",
    "contact": "1234567890",
    "city": "Madrid",
    "country": "ESPAÑA",
    "location": "Calle Principal 123",
    "menu": "Desayunos, Almuerzos, Cenas"
  }' \
  -F "images=@photo1.jpg" \
  -F "images=@photo2.png"
```

**Notas:**
- Solo usuarios con rol BUSINESS pueden acceder a este endpoint
- Las imágenes se almacenan en la carpeta `/images/` con nombres UUID
- La tabla `images` guarda el ID (UUID) y la extensión del archivo
- El negocio se crea con `is_enable = true` por defecto
- El negocio aparece en las búsquedas de turistas según su ciudad y país