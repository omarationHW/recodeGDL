# Documentación Técnica - Stored Procedures FirmaUsuario

## Información General

**Componente:** FirmaUsuario.vue
**Esquema:** INFORMIX
**Base de Datos:** padron_licencias
**Generado:** 2025-09-23

## Descripción del Sistema

El sistema de FirmaUsuario proporciona funcionalidades de autenticación de usuarios mediante PIN, gestión de sesiones y control de acceso. Está diseñado para integrarse con el componente Vue.js `firmausuario.vue`.

## Estructura de Tablas

### 1. informix.usuarios_autenticacion

Tabla principal que almacena los usuarios con capacidad de autenticación por PIN.

```sql
CREATE TABLE informix.usuarios_autenticacion (
    id SERIAL PRIMARY KEY,
    usuario VARCHAR(100) UNIQUE NOT NULL,
    pin VARCHAR(255) NOT NULL, -- PIN hasheado con bcrypt
    estado INTEGER DEFAULT 1 CHECK (estado IN (0, 1)), -- 0=Bloqueado, 1=Activo
    intentos_fallidos INTEGER DEFAULT 0,
    ultimo_acceso TIMESTAMP,
    sesion_activa BOOLEAN DEFAULT FALSE,
    observaciones TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);
```

**Campos:**
- `id`: Identificador único del usuario
- `usuario`: Nombre de usuario único
- `pin`: PIN hasheado usando bcrypt
- `estado`: Estado del usuario (0=Bloqueado, 1=Activo)
- `intentos_fallidos`: Contador de intentos de autenticación fallidos
- `ultimo_acceso`: Timestamp del último acceso exitoso
- `sesion_activa`: Indica si el usuario tiene una sesión activa
- `observaciones`: Notas adicionales sobre el usuario

### 2. informix.sesiones_usuarios

Tabla que registra el historial de sesiones de los usuarios.

```sql
CREATE TABLE informix.sesiones_usuarios (
    id SERIAL PRIMARY KEY,
    usuario_autenticacion_id INTEGER REFERENCES informix.usuarios_autenticacion(id),
    fecha_inicio TIMESTAMP DEFAULT NOW(),
    fecha_fin TIMESTAMP NULL,
    ip_address INET,
    user_agent TEXT,
    token_sesion VARCHAR(255),
    activa BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT NOW()
);
```

## Stored Procedures Disponibles

### 1. sp_firmausuario_list

**Propósito:** Obtener lista paginada de usuarios con filtros opcionales.

**Sintaxis:**
```sql
SELECT * FROM informix.sp_firmausuario_list(
    p_usuario VARCHAR DEFAULT NULL,
    p_estado INTEGER DEFAULT NULL,
    p_sesion_activa INTEGER DEFAULT NULL,
    p_limite INTEGER DEFAULT 10,
    p_offset INTEGER DEFAULT 0
);
```

**Parámetros:**
- `p_usuario`: Filtro por nombre de usuario (búsqueda parcial con ILIKE)
- `p_estado`: Filtro por estado (0=Bloqueado, 1=Activo)
- `p_sesion_activa`: Filtro por sesión activa (0=Sin sesión, 1=Con sesión)
- `p_limite`: Número máximo de registros a retornar
- `p_offset`: Número de registros a omitir (para paginación)

**Retorna:**
- `id`: ID del usuario
- `usuario`: Nombre de usuario
- `pin`: Siempre retorna '****' por seguridad
- `ultimo_acceso`: Timestamp del último acceso
- `sesion_activa`: Estado de la sesión
- `intentos_fallidos`: Número de intentos fallidos
- `estado`: Estado del usuario
- `observaciones`: Notas del usuario
- `total_registros`: Total de registros para paginación

**Ejemplo de uso:**
```sql
-- Obtener todos los usuarios activos
SELECT * FROM informix.sp_firmausuario_list(NULL, 1);

-- Buscar usuario específico
SELECT * FROM informix.sp_firmausuario_list('admin');

-- Paginación: primeros 5 registros
SELECT * FROM informix.sp_firmausuario_list(NULL, NULL, NULL, 5, 0);
```

### 2. sp_firmausuario_mantener

**Propósito:** Operaciones CRUD (Create, Read, Update, Delete) para usuarios.

**Sintaxis:**
```sql
SELECT * FROM informix.sp_firmausuario_mantener(
    p_operacion CHAR(1),
    p_id INTEGER DEFAULT NULL,
    p_usuario VARCHAR DEFAULT NULL,
    p_pin VARCHAR DEFAULT NULL,
    p_estado INTEGER DEFAULT 1,
    p_reset_intentos INTEGER DEFAULT 0,
    p_observaciones TEXT DEFAULT NULL
);
```

**Parámetros:**
- `p_operacion`: Tipo de operación ('I'=Insert, 'U'=Update, 'D'=Delete)
- `p_id`: ID del usuario (requerido para Update y Delete)
- `p_usuario`: Nombre de usuario
- `p_pin`: PIN en texto plano (se hashea automáticamente)
- `p_estado`: Estado del usuario
- `p_reset_intentos`: Si es 1, resetea los intentos fallidos a 0
- `p_observaciones`: Notas del usuario

**Retorna:**
- `success`: TRUE/FALSE indicando si la operación fue exitosa
- `message`: Mensaje descriptivo del resultado
- `id`: ID del usuario afectado

**Ejemplos de uso:**

**Crear usuario:**
```sql
SELECT * FROM informix.sp_firmausuario_mantener(
    'I', NULL, 'nuevo_usuario', '1234', 1, 0, 'Usuario nuevo'
);
```

**Actualizar usuario:**
```sql
SELECT * FROM informix.sp_firmausuario_mantener(
    'U', 1, NULL, '5678', 1, 1, 'PIN actualizado'
);
```

**Eliminar usuario:**
```sql
SELECT * FROM informix.sp_firmausuario_mantener('D', 1);
```

### 3. sp_firmausuario_autenticar

**Propósito:** Autenticar usuario con PIN y crear sesión.

**Sintaxis:**
```sql
SELECT * FROM informix.sp_firmausuario_autenticar(
    p_usuario VARCHAR,
    p_pin VARCHAR
);
```

**Parámetros:**
- `p_usuario`: Nombre de usuario
- `p_pin`: PIN en texto plano

**Retorna:**
- `success`: TRUE/FALSE indicando si la autenticación fue exitosa
- `message`: Mensaje descriptivo del resultado
- `autenticado`: TRUE si el usuario fue autenticado correctamente
- `usuario_id`: ID del usuario autenticado
- `sesion_token`: Token único de la sesión (si la autenticación fue exitosa)

**Lógica de seguridad:**
- Bloquea automáticamente usuarios con 3 o más intentos fallidos
- Incrementa contador de intentos fallidos en cada PIN incorrecto
- Resetea intentos fallidos en autenticación exitosa
- Cierra sesiones anteriores al crear una nueva
- Actualiza timestamp de último acceso

**Ejemplo de uso:**
```sql
SELECT * FROM informix.sp_firmausuario_autenticar('admin', '1234');
```

### 4. sp_firmausuario_sesiones

**Propósito:** Obtener historial de sesiones de un usuario.

**Sintaxis:**
```sql
SELECT * FROM informix.sp_firmausuario_sesiones(p_usuario VARCHAR);
```

**Parámetros:**
- `p_usuario`: Nombre de usuario

**Retorna:**
- `id`: ID de la sesión
- `fecha_inicio`: Inicio de la sesión
- `fecha_fin`: Fin de la sesión (NULL si está activa)
- `ip_address`: Dirección IP de la sesión
- `user_agent`: User agent del navegador
- `activa`: TRUE si la sesión está activa
- `duracion_minutos`: Duración de la sesión en minutos

**Ejemplo de uso:**
```sql
SELECT * FROM informix.sp_firmausuario_sesiones('admin');
```

### 5. sp_firmausuario_cerrar_sesion

**Propósito:** Cerrar sesiones activas de un usuario.

**Sintaxis:**
```sql
SELECT * FROM informix.sp_firmausuario_cerrar_sesion(
    p_usuario VARCHAR,
    p_token_sesion VARCHAR DEFAULT NULL
);
```

**Parámetros:**
- `p_usuario`: Nombre de usuario
- `p_token_sesion`: Token específico de sesión (opcional)

**Retorna:**
- `success`: TRUE/FALSE indicando si la operación fue exitosa
- `message`: Mensaje descriptivo del resultado

**Comportamiento:**
- Si se proporciona `p_token_sesion`, cierra solo esa sesión específica
- Si `p_token_sesion` es NULL, cierra todas las sesiones activas del usuario
- Marca `sesion_activa = FALSE` en la tabla usuarios_autenticacion

**Ejemplo de uso:**
```sql
-- Cerrar todas las sesiones del usuario
SELECT * FROM informix.sp_firmausuario_cerrar_sesion('admin');

-- Cerrar sesión específica
SELECT * FROM informix.sp_firmausuario_cerrar_sesion('admin', 'sess_1234567890_1');
```

## Integración con Vue.js

### Mapeo de operaciones del componente a SP

| Operación Vue.js | Stored Procedure | Descripción |
|------------------|------------------|-------------|
| `loadUsuarios()` | `sp_firmausuario_list` | Cargar lista de usuarios con filtros |
| `saveItem()` | `sp_firmausuario_mantener` | Crear/actualizar usuario |
| `deleteItem()` | `sp_firmausuario_mantener` | Eliminar usuario |
| `authenticateUser()` | `sp_firmausuario_autenticar` | Autenticar usuario con PIN |
| `viewSessions()` | `sp_firmausuario_sesiones` | Ver historial de sesiones |

### Formato de llamada API

El componente Vue.js realiza llamadas POST a `/api/generic` con el siguiente formato:

```javascript
{
  eRequest: {
    Operacion: "sp_firmausuario_list",
    Base: "padron_licencias",
    Parametros: [
      { nombre: "p_usuario", valor: "admin" },
      { nombre: "p_estado", valor: 1 }
    ],
    Tenant: "informix"
  }
}
```

## Datos de Prueba

El script incluye usuarios de ejemplo:

- **admin** (PIN: 1234) - Usuario administrador activo
- **user1** (PIN: 5678) - Usuario operativo activo
- **user2** (PIN: 9012) - Usuario bloqueado
- **test** (PIN: 0000) - Usuario de pruebas activo

## Seguridad

### Características implementadas:

1. **Hashing de PINs:** Los PINs se almacenan hasheados usando bcrypt
2. **Bloqueo automático:** Usuarios se bloquean tras 3 intentos fallidos
3. **Control de sesiones:** Una sesión activa por usuario
4. **Tokens únicos:** Cada sesión tiene un token único
5. **Auditoría:** Historial completo de sesiones

### Consideraciones de seguridad:

- Los PINs nunca se muestran en texto plano
- Las consultas usan parámetros para prevenir SQL injection
- Los intentos fallidos se registran y controlan
- Las sesiones tienen timestamps para auditoría

## Instalación y Configuración

### 1. Ejecutar el script principal:
```bash
psql -d padron_licencias -f SP_FIRMAUSUARIO_INFORMIX_COMPLETE.sql
```

### 2. Validar la instalación:
```bash
psql -d padron_licencias -f VALIDATE_FIRMAUSUARIO_SPS.sql
```

### 3. Verificar permisos:
Los scripts otorgan automáticamente permisos necesarios sobre tablas y funciones.

## Mantenimiento

### Limpieza de sesiones antigas:
```sql
-- Eliminar sesiones inactivas de más de 30 días
DELETE FROM informix.sesiones_usuarios
WHERE activa = FALSE
  AND fecha_fin < NOW() - INTERVAL '30 days';
```

### Resetear intentos fallidos:
```sql
-- Resetear intentos fallidos de todos los usuarios
UPDATE informix.usuarios_autenticacion
SET intentos_fallidos = 0, updated_at = NOW();
```

### Desbloquear usuarios:
```sql
-- Desbloquear usuario específico
UPDATE informix.usuarios_autenticacion
SET estado = 1, intentos_fallidos = 0, updated_at = NOW()
WHERE usuario = 'nombre_usuario';
```

## Troubleshooting

### Problemas comunes:

1. **Usuario no puede autenticarse:**
   - Verificar que `estado = 1`
   - Verificar que `intentos_fallidos < 3`
   - Probar resetear PIN

2. **Sesiones no se crean:**
   - Verificar permisos en tabla `sesiones_usuarios`
   - Verificar que la función `sp_firmausuario_autenticar` tiene permisos de ejecución

3. **Paginación no funciona:**
   - Verificar que los parámetros `p_limite` y `p_offset` se pasan correctamente
   - El total de registros se calcula en cada llamada para precisión

## Versiones y Compatibilidad

- **PostgreSQL:** 12+
- **Esquema:** informix
- **Extensiones requeridas:** pgcrypto (para funciones de hash)
- **Vue.js:** Compatible con componente firmausuario.vue existente