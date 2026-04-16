# Documentación de Experiencias

## Obtener Experiencias del Usuario

Retorna todas las experiencias del usuario autenticado.

**URL:** `GET /api/v1/experiences`

**Encabezados:**
| Campo | Valor |
|-------|-------|
| Authorization | Bearer {TOKEN_JWT} |

**Parámetros de query:**
| Campo | Tipo | Obligatorio | Default | Descripción |
|-------|------|-------------|---------|-------------|
| includeDisabled | boolean | No | false | Incluir experiencias deshabilitadas |

**Respuestas:**

- **200 OK:** Lista de experiencias del usuario
- **400 Bad Request:** Encabezado Authorization faltante

**Ejemplo de solicitud:**

```bash
curl -X GET "http://localhost:8080/api/v1/experiences" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."

curl -X GET "http://localhost:8080/api/v1/experiences?includeDisabled=true" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

**Ejemplo de respuesta:**

```json
[
  {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "name": "Tour por la Ciudad",
    "description": "Un tour guiadas por los lugares más emblemáticos",
    "contact": "1234567890",
    "city": "Madrid",
    "country": "ESPAÑA",
    "location": "Plaza Mayor",
    "price": 50.0,
    "startingDate": "2026-06-01",
    "endDate": "2026-06-10",
    "isEnable": true,
    "images": [{ "id": "uuid1", "extension": "jpg" }]
  }
]
```

**Notas:**

- El usuario debe tener un token JWT válido
- Por defecto solo retorna experiencias con `is_enable=true`
- El campo `isEnable` indica si la experiencia está habilitada
- Cuando `includeDisabled=true`, retorna todas las experiencias (habilitadas y deshabilitadas)

## Crear Experiencia

Crea una nueva experiencia asociada al usuario EXPERIENCE autenticado.

**URL:** `POST /api/v1/experiences`

**Encabezados:**
| Campo | Valor |
|-------|-------|
| Authorization | Bearer {TOKEN_JWT} |

**Cuerpo de la solicitud (JSON):**
| Campo | Tipo | Obligatorio | Descripción |
|-------|------|-------------|-------------|
| name | String | Sí | Nombre de la experiencia |
| description | String | No | Descripción de la experiencia |
| contact | String | Sí | Teléfono de contacto |
| city | String | Sí | Ciudad |
| country | String | Sí | País |
| location | String | No | Dirección/ubicación |
| price | Double | Sí | Precio de la experiencia |
| startingDate | Date | Sí | Fecha de inicio (YYYY-MM-DD) |
| endDate | Date | Sí | Fecha de fin (YYYY-MM-DD) |

**Imágenes (multipart/form-data):**
| Campo | Tipo | Obligatorio | Descripción |
|-------|------|-------------|-------------|
| images | File[] | No | Imágenes (máximo 3, formatos: jpg, png, webp) |

**Respuestas:**

- **201 Created:** Experiencia creada exitosamente
- **400 Bad Request:** Datos faltantes, inválidos o más de 3 imágenes
- **401 Unauthorized:** Token inválido o usuario no tiene rol EXPERIENCE

**Ejemplo de solicitud:**

```bash
curl -X POST "http://localhost:8080/api/v1/experiences" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Tour por la Ciudad",
    "description": "Un tour guiadas por los lugares más emblemáticos",
    "contact": "1234567890",
    "city": "Madrid",
    "country": "ESPAÑA",
    "location": "Plaza Mayor",
    "price": 50.0,
    "startingDate": "2026-06-01",
    "endDate": "2026-06-10"
  }' \
  -F "images=@photo1.jpg" \
  -F "images=@photo2.png"
```

**Notas:**

- Solo usuarios con rol EXPERIENCE pueden acceder a este endpoint
- Las imágenes se almacenan en la carpeta `/images/` con nombres UUID
- La tabla `images` guarda el ID (UUID) y la extensión del archivo
- La experiencia se crea con `is_enable = true` por defecto
- La experiencia aparece en las búsquedas de turistas según su ciudad y país
- Las fechas de inicio y fin son en formato DATE (YYYY-MM-DD)

## Actualizar Experiencia

Actualiza una experiencia existente. Solo el EXPERIENCE que creó la experiencia o un ADMIN pueden actualizarla.

**URL:** `PUT /api/v1/experiences/{experienceId}`

**Encabezados:**
| Campo | Valor |
|-------|-------|
| Authorization | Bearer {TOKEN_JWT} |

**Parámetros de ruta:**
| Campo | Tipo | Descripción |
|-------|------|-------------|
| experienceId | UUID | ID de la experiencia a actualizar |

**Cuerpo de la solicitud (JSON):**
| Campo | Tipo | Obligatorio | Descripción |
|-------|------|-------------|-------------|
| name | String | Sí | Nombre de la experiencia |
| description | String | No | Descripción de la experiencia |
| contact | String | Sí | Teléfono de contacto |
| city | String | Sí | Ciudad |
| country | String | Sí | País |
| location | String | No | Dirección/ubicación |
| price | Double | Sí | Precio de la experiencia |
| startingDate | Date | Sí | Fecha de inicio (YYYY-MM-DD) |
| endDate | Date | Sí | Fecha de fin (YYYY-MM-DD) |

**Imágenes (multipart/form-data):**
| Campo | Tipo | Obligatorio | Descripción |
|-------|------|-------------|-------------|
| images | File[] | No | Imágenes (máximo 3, formatos: jpg, png, webp). Si se envían, reemplazan todas las imágenes existentes |

**Respuestas:**

- **200 OK:** Experiencia actualizada exitosamente
- **400 Bad Request:** Datos faltantes, inválidos o más de 3 imágenes
- **401 Unauthorized:** Token inválido
- **403 Forbidden:** Usuario no es el propietario ni ADMIN

**Ejemplo de solicitud:**

```bash
curl -X PUT "http://localhost:8080/api/v1/experiences/550e8400-e29b-41d4-a716-446655440000" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Tour por la Ciudad Actualizado",
    "description": "Nueva descripción",
    "contact": "9876543210",
    "city": "Barcelona",
    "country": "ESPAÑA",
    "location": "Nueva ubicación",
    "price": 75.0,
    "startingDate": "2026-07-01",
    "endDate": "2026-07-10"
  }' \
  -F "images=@newphoto1.jpg"
```

**Notas:**

- Solo el EXPERIENCE que creó la experiencia o un usuario con rol ADMIN pueden actualizarlo
- Las imágenes existentes serán eliminadas y reemplazadas por las nuevas
- Todos los campos son requeridos (full update)
- La experiencia debe existir previamente

## Habilitar/Deshabilitar Experiencia

Habilita o deshabilita una experiencia existente.

**URL:** `PATCH /api/v1/experiences/{experienceId}`

**Encabezados:**
| Campo | Valor |
|-------|-------|
| Authorization | Bearer {TOKEN_JWT} |

**Parámetros de ruta:**
| Campo | Tipo | Descripción |
|-------|------|-------------|
| experienceId | UUID | ID de la experiencia |

**Parámetros de query:**
| Campo | Tipo | Obligatorio | Descripción |
|-------|------|-------------|-------------|
| enabled | boolean | Sí | true para habilitar, false para deshabilitar |

**Respuestas:**

- **200 OK:** Experiencia actualizada exitosamente
- **400 Bad Request:** Encabezado Authorization faltante
- **403 Forbidden:** Usuario no es el propietario ni ADMIN

**Ejemplo de solicitud:**

```bash
# Habilitar experiencia
curl -X PATCH "http://localhost:8080/api/v1/experiences/550e8400-e29b-41d4-a716-446655440000?enabled=true" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."

# Deshabilitar experiencia
curl -X PATCH "http://localhost:8080/api/v1/experiences/550e8400-e29b-41d4-a716-446655440000?enabled=false" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

**Notas:**

- Solo el EXPERIENCE que creó la experiencia o un usuario con rol ADMIN pueden habilitar/deshabilitarla
- Las experiencias deshabilitadas no aparecen en las búsquedas de turistas

## Eliminar Experiencia

Elimina una experiencia existente. Solo el EXPERIENCE que creó la experiencia o un ADMIN pueden eliminarla.

**URL:** `DELETE /api/v1/experiences/{experienceId}`

**Encabezados:**
| Campo | Valor |
|-------|-------|
| Authorization | Bearer {TOKEN_JWT} |

**Parámetros de ruta:**
| Campo | Tipo | Descripción |
|-------|------|-------------|
| experienceId | UUID | ID de la experiencia a eliminar |

**Respuestas:**

- **200 OK:** Experiencia eliminada exitosamente
- **400 Bad Request:** Encabezado Authorization faltante
- **403 Forbidden:** Usuario no es el propietario, no es ADMIN, o experiencia no existe

**Ejemplo de solicitud:**

```bash
curl -X DELETE "http://localhost:8080/api/v1/experiences/550e8400-e29b-41d4-a716-446655440000" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

**Notas:**

- Solo el EXPERIENCE que creó la experiencia o un usuario con rol ADMIN pueden eliminarla
- Todas las imágenes asociadas a la experiencia también serán eliminadas (archivos y registros en la base de datos)
- Eliminar una experiencia que no existe retorna 403 Forbidden

