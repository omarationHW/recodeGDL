# Documentación - Stored Procedures de Consulta de Usuarios

**Componente:** consultausuariosfrm
**Módulo:** padron_licencias
**Schema:** comun
**Total SPs:** 9
**Fecha:** 2025-11-20
**Estado:** IMPLEMENTADO Y PROBADO

---

## Índice

1. [Resumen General](#resumen-general)
2. [Prerequisitos](#prerequisitos)
3. [Stored Procedures - Consultas](#stored-procedures---consultas)
4. [Stored Procedures - Catálogos](#stored-procedures---catálogos)
5. [Stored Procedures - CRUD](#stored-procedures---crud)
6. [Ejemplos de Uso desde Vue](#ejemplos-de-uso-desde-vue)
7. [Seguridad y Mejores Prácticas](#seguridad-y-mejores-prácticas)
8. [Troubleshooting](#troubleshooting)

---

## Resumen General

Este conjunto de stored procedures proporciona funcionalidad completa para la gestión de usuarios del sistema, incluyendo:

- **Consultas:** Búsqueda de usuarios por diferentes criterios
- **Catálogos:** Obtención de dependencias y departamentos
- **CRUD:** Creación, actualización y baja de usuarios

### Características Principales

✅ **Seguridad:** Contraseñas hasheadas con bcrypt (factor 8)
✅ **Validaciones:** Validación completa de datos antes de operaciones
✅ **Case-Insensitive:** Búsquedas sin distinción de mayúsculas/minúsculas
✅ **Soft Delete:** Baja lógica con fecha (no se eliminan registros)
✅ **API Compatible:** 100% compatible con API genérica de RefactorX

---

## Prerequisitos

### 1. Extensión PostgreSQL Requerida

```sql
CREATE EXTENSION IF NOT EXISTS pgcrypto;
```

### 2. Schema Requerido

```sql
CREATE SCHEMA IF NOT EXISTS comun;
```

### 3. Tablas Requeridas

#### comun.usuarios
```sql
- usuario (VARCHAR, PK) - Nombre de usuario (lowercase)
- nombres (VARCHAR) - Nombre completo (uppercase)
- clave (VARCHAR) - Contraseña hasheada (bcrypt)
- cvedepto (INTEGER, FK) - Clave del departamento
- nivel (INTEGER) - Nivel de acceso: 1, 5, 9, 10
- fecalt (DATE) - Fecha de alta
- fecbaj (DATE) - Fecha de baja (NULL = activo)
- feccap (TIMESTAMP) - Fecha de captura
- capturo (VARCHAR) - Usuario que capturó
```

#### comun.deptos
```sql
- cvedepto (INTEGER, PK) - Clave del departamento
- nombredepto (VARCHAR) - Nombre del departamento
- telefono (VARCHAR) - Teléfono
- cvedependencia (INTEGER, FK) - Clave de dependencia
```

#### comun.c_dependencias
```sql
- id_dependencia (INTEGER, PK) - ID de la dependencia
- descripcion (VARCHAR) - Descripción
- clave (VARCHAR) - Clave
```

---

## Stored Procedures - Consultas

### 1. get_all_usuarios()

**Descripción:** Obtiene todos los usuarios del sistema con información completa.

**Parámetros:** Ninguno

**Retorna:**
```sql
TABLE (
    usuario VARCHAR,
    nombres VARCHAR,
    cvedepto INTEGER,
    nivel INTEGER,
    fecalt DATE,
    fecbaj DATE,
    feccap TIMESTAMP,
    capturo VARCHAR,
    nombredepto VARCHAR,
    telefono VARCHAR,
    cvedependencia INTEGER,
    descripcion VARCHAR
)
```

**Ejemplo SQL:**
```sql
SELECT * FROM comun.get_all_usuarios();
```

**Ejemplo API (desde Vue):**
```javascript
const response = await execute(
  'get_all_usuarios',
  'padron_licencias',
  [],
  'guadalajara',
  null,
  'comun'
)
```

**Resultado Esperado:**
```json
{
  "result": [
    {
      "usuario": "jperez",
      "nombres": "JUAN PEREZ LOPEZ",
      "cvedepto": 1,
      "nivel": 5,
      "fecalt": "2024-01-15",
      "fecbaj": null,
      "feccap": "2024-01-15T10:30:00",
      "capturo": "admin",
      "nombredepto": "SISTEMAS",
      "telefono": "3312345678",
      "cvedependencia": 1,
      "descripcion": "DIRECCION DE TECNOLOGIAS"
    }
  ]
}
```

---

### 2. consulta_usuario_por_usuario(p_usuario VARCHAR)

**Descripción:** Busca un usuario específico por su nombre de usuario.

**Parámetros:**
- `p_usuario` (VARCHAR) - Nombre de usuario (case-insensitive)

**Retorna:**
```sql
TABLE (
    descripcion VARCHAR,
    nombredepto VARCHAR,
    telefono VARCHAR,
    usuario VARCHAR,
    nombres VARCHAR,
    fecalt DATE,
    fecbaj DATE,
    feccap TIMESTAMP,
    capturo VARCHAR,
    cvedepto INTEGER,
    nivel INTEGER,
    cvedependencia INTEGER
)
```

**Ejemplo SQL:**
```sql
SELECT * FROM comun.consulta_usuario_por_usuario('jperez');
```

**Ejemplo API (desde Vue):**
```javascript
const response = await execute(
  'consulta_usuario_por_usuario',
  'padron_licencias',
  [
    { nombre: 'p_usuario', valor: 'jperez', tipo: 'string' }
  ],
  'guadalajara',
  null,
  'comun'
)
```

---

### 3. consulta_usuario_por_nombre(p_nombre VARCHAR)

**Descripción:** Busca usuarios por coincidencia de nombre completo (prefijo).

**Parámetros:**
- `p_nombre` (VARCHAR) - Prefijo del nombre a buscar (case-insensitive)

**Retorna:** Igual que consulta_usuario_por_usuario

**Ejemplo SQL:**
```sql
-- Buscar usuarios cuyo nombre comience con "JUAN"
SELECT * FROM comun.consulta_usuario_por_nombre('JUAN');
```

**Ejemplo API (desde Vue):**
```javascript
const response = await execute(
  'consulta_usuario_por_nombre',
  'padron_licencias',
  [
    { nombre: 'p_nombre', valor: 'JUAN', tipo: 'string' }
  ],
  'guadalajara',
  null,
  'comun'
)
```

**Características:**
- Búsqueda por prefijo: "JUAN" encuentra "JUAN PEREZ", "JUANA LOPEZ", etc.
- Case-insensitive: "juan" = "JUAN" = "Juan"
- Resultados ordenados alfabéticamente

---

### 4. consulta_usuario_por_depto(p_id_dependencia INTEGER, p_cvedepto INTEGER)

**Descripción:** Busca usuarios de un departamento específico.

**Parámetros:**
- `p_id_dependencia` (INTEGER) - ID de la dependencia
- `p_cvedepto` (INTEGER) - Clave del departamento

**Retorna:** Igual que consulta_usuario_por_usuario

**Ejemplo SQL:**
```sql
SELECT * FROM comun.consulta_usuario_por_depto(1, 5);
```

**Ejemplo API (desde Vue):**
```javascript
const response = await execute(
  'consulta_usuario_por_depto',
  'padron_licencias',
  [
    { nombre: 'p_id_dependencia', valor: 1, tipo: 'integer' },
    { nombre: 'p_cvedepto', valor: 5, tipo: 'integer' }
  ],
  'guadalajara',
  null,
  'comun'
)
```

---

## Stored Procedures - Catálogos

### 5. get_dependencias()

**Descripción:** Obtiene el catálogo completo de dependencias.

**Parámetros:** Ninguno

**Retorna:**
```sql
TABLE (
    id_dependencia INTEGER,
    descripcion VARCHAR,
    clave VARCHAR
)
```

**Ejemplo SQL:**
```sql
SELECT * FROM comun.get_dependencias();
```

**Ejemplo API (desde Vue):**
```javascript
const response = await execute(
  'get_dependencias',
  'padron_licencias',
  [],
  'guadalajara',
  null,
  'comun'
)
```

**Resultado Esperado:**
```json
{
  "result": [
    {
      "id_dependencia": 1,
      "descripcion": "DIRECCION DE TECNOLOGIAS",
      "clave": "DT"
    },
    {
      "id_dependencia": 2,
      "descripcion": "SECRETARIA DE ADMINISTRACION",
      "clave": "SA"
    }
  ]
}
```

---

### 6. get_deptos_by_dependencia(p_id_dependencia INTEGER)

**Descripción:** Obtiene los departamentos de una dependencia específica.

**Parámetros:**
- `p_id_dependencia` (INTEGER) - ID de la dependencia

**Retorna:**
```sql
TABLE (
    cvedepto INTEGER,
    nombredepto VARCHAR,
    telefono VARCHAR,
    cvedependencia INTEGER
)
```

**Ejemplo SQL:**
```sql
SELECT * FROM comun.get_deptos_by_dependencia(1);
```

**Ejemplo API (desde Vue):**
```javascript
const response = await execute(
  'get_deptos_by_dependencia',
  'padron_licencias',
  [
    { nombre: 'p_id_dependencia', valor: 1, tipo: 'integer' }
  ],
  'guadalajara',
  null,
  'comun'
)
```

**Uso típico:** Cargar combo cascada de Dependencia → Departamento

---

## Stored Procedures - CRUD

### 7. crear_usuario()

**Descripción:** Crea un nuevo usuario en el sistema.

**Parámetros:**
- `p_usuario` (VARCHAR) - Nombre de usuario (será convertido a lowercase)
- `p_nombres` (VARCHAR) - Nombre completo (será convertido a uppercase)
- `p_clave` (VARCHAR) - Contraseña en texto plano (será hasheada con bcrypt)
- `p_cvedepto` (INTEGER) - Clave del departamento
- `p_nivel` (INTEGER) - Nivel de acceso: 1, 5, 9, 10
- `p_capturo` (VARCHAR) - Usuario que registra

**Retorna:**
```sql
TABLE (
    success BOOLEAN,
    message TEXT
)
```

**Ejemplo SQL:**
```sql
SELECT * FROM comun.crear_usuario(
    'jperez',
    'Juan Perez Lopez',
    'password123',
    5,
    5,
    'admin'
);
```

**Ejemplo API (desde Vue):**
```javascript
const response = await execute(
  'crear_usuario',
  'padron_licencias',
  [
    { nombre: 'p_usuario', valor: 'jperez', tipo: 'string' },
    { nombre: 'p_nombres', valor: 'JUAN PEREZ LOPEZ', tipo: 'string' },
    { nombre: 'p_clave', valor: 'password123', tipo: 'string' },
    { nombre: 'p_cvedepto', valor: 5, tipo: 'integer' },
    { nombre: 'p_nivel', valor: 5, tipo: 'integer' },
    { nombre: 'p_capturo', valor: 'sistema', tipo: 'string' }
  ],
  'guadalajara',
  null,
  'comun'
)
```

**Respuesta Exitosa:**
```json
{
  "result": [
    {
      "success": true,
      "message": "Usuario creado exitosamente"
    }
  ]
}
```

**Respuesta con Error:**
```json
{
  "result": [
    {
      "success": false,
      "message": "El usuario ya existe"
    }
  ]
}
```

**Validaciones:**
- ✅ Usuario único (no duplicados)
- ✅ Departamento debe existir
- ✅ Nivel debe ser 1, 5, 9 o 10
- ✅ Contraseña hasheada automáticamente con bcrypt

**Transformaciones Automáticas:**
- `p_usuario` → lowercase
- `p_nombres` → UPPERCASE
- `p_clave` → hash bcrypt (factor 8)

---

### 8. actualizar_usuario()

**Descripción:** Actualiza los datos de un usuario existente.

**Parámetros:**
- `p_usuario` (VARCHAR) - Nombre de usuario (identificador, no se modifica)
- `p_nombres` (VARCHAR) - Nombre completo actualizado
- `p_clave` (VARCHAR) - Nueva contraseña (NULL o vacío = mantener actual)
- `p_cvedepto` (INTEGER) - Clave del departamento
- `p_nivel` (INTEGER) - Nivel de acceso
- `p_capturo` (VARCHAR) - Usuario que modifica (no usado actualmente)

**Retorna:**
```sql
TABLE (
    success BOOLEAN,
    message TEXT
)
```

**Ejemplo SQL - Actualizar sin cambiar contraseña:**
```sql
SELECT * FROM comun.actualizar_usuario(
    'jperez',
    'Juan Alberto Perez Lopez',
    NULL,
    5,
    9,
    'admin'
);
```

**Ejemplo SQL - Actualizar con nueva contraseña:**
```sql
SELECT * FROM comun.actualizar_usuario(
    'jperez',
    'Juan Alberto Perez Lopez',
    'newpassword456',
    5,
    9,
    'admin'
);
```

**Ejemplo API (desde Vue) - Sin cambiar contraseña:**
```javascript
const response = await execute(
  'actualizar_usuario',
  'padron_licencias',
  [
    { nombre: 'p_usuario', valor: 'jperez', tipo: 'string' },
    { nombre: 'p_nombres', valor: 'JUAN ALBERTO PEREZ LOPEZ', tipo: 'string' },
    { nombre: 'p_clave', valor: null, tipo: 'string' },
    { nombre: 'p_cvedepto', valor: 5, tipo: 'integer' },
    { nombre: 'p_nivel', valor: 9, tipo: 'integer' },
    { nombre: 'p_capturo', valor: 'sistema', tipo: 'string' }
  ],
  'guadalajara',
  null,
  'comun'
)
```

**Características Importantes:**
- Si `p_clave` es NULL o vacío: NO se actualiza la contraseña
- Si `p_clave` tiene valor: se hashea y actualiza
- El nombre de usuario NO se puede cambiar (es identificador)

**Validaciones:**
- ✅ Usuario debe existir
- ✅ Departamento debe existir
- ✅ Nivel debe ser 1, 5, 9 o 10

---

### 9. dar_baja_usuario()

**Descripción:** Da de baja un usuario (soft delete - marca fecha de baja).

**Parámetros:**
- `p_usuario` (VARCHAR) - Nombre de usuario
- `p_capturo` (VARCHAR) - Usuario que realiza la baja (no usado actualmente)

**Retorna:**
```sql
TABLE (
    success BOOLEAN,
    message TEXT
)
```

**Ejemplo SQL:**
```sql
SELECT * FROM comun.dar_baja_usuario('jperez', 'admin');
```

**Ejemplo API (desde Vue):**
```javascript
const response = await execute(
  'dar_baja_usuario',
  'padron_licencias',
  [
    { nombre: 'p_usuario', valor: 'jperez', tipo: 'string' },
    { nombre: 'p_capturo', valor: 'sistema', tipo: 'string' }
  ],
  'guadalajara',
  null,
  'comun'
)
```

**Respuesta Exitosa:**
```json
{
  "result": [
    {
      "success": true,
      "message": "Usuario dado de baja exitosamente"
    }
  ]
}
```

**Características:**
- ✅ **Soft Delete:** No elimina el registro, marca `fecbaj = CURRENT_DATE`
- ✅ Los usuarios dados de baja siguen apareciendo en consultas
- ✅ No se puede dar de baja un usuario ya dado de baja

**Validaciones:**
- ✅ Usuario debe existir
- ✅ Usuario no debe estar ya dado de baja

---

## Ejemplos de Uso desde Vue

### Flujo Completo: Cargar → Buscar → Crear → Actualizar → Dar de Baja

```javascript
import { useApi } from '@/composables/useApi'

const { execute } = useApi()

// 1. Cargar todas las dependencias
async function cargarDependencias() {
  const response = await execute(
    'get_dependencias',
    'padron_licencias',
    [],
    'guadalajara',
    null,
    'comun'
  )
  return response.result
}

// 2. Cargar departamentos de una dependencia
async function cargarDepartamentos(idDependencia) {
  const response = await execute(
    'get_deptos_by_dependencia',
    'padron_licencias',
    [
      { nombre: 'p_id_dependencia', valor: idDependencia, tipo: 'integer' }
    ],
    'guadalajara',
    null,
    'comun'
  )
  return response.result
}

// 3. Cargar todos los usuarios
async function cargarTodosUsuarios() {
  const response = await execute(
    'get_all_usuarios',
    'padron_licencias',
    [],
    'guadalajara',
    null,
    'comun'
  )
  return response.result
}

// 4. Buscar usuario por nombre de usuario
async function buscarUsuario(usuario) {
  const response = await execute(
    'consulta_usuario_por_usuario',
    'padron_licencias',
    [
      { nombre: 'p_usuario', valor: usuario, tipo: 'string' }
    ],
    'guadalajara',
    null,
    'comun'
  )
  return response.result
}

// 5. Crear nuevo usuario
async function crearUsuario(datos) {
  const response = await execute(
    'crear_usuario',
    'padron_licencias',
    [
      { nombre: 'p_usuario', valor: datos.usuario.toLowerCase(), tipo: 'string' },
      { nombre: 'p_nombres', valor: datos.nombres.toUpperCase(), tipo: 'string' },
      { nombre: 'p_clave', valor: datos.clave, tipo: 'string' },
      { nombre: 'p_cvedepto', valor: parseInt(datos.cvedepto), tipo: 'integer' },
      { nombre: 'p_nivel', valor: datos.nivel, tipo: 'integer' },
      { nombre: 'p_capturo', valor: 'sistema', tipo: 'string' }
    ],
    'guadalajara',
    null,
    'comun'
  )
  return response.result[0]
}

// 6. Actualizar usuario
async function actualizarUsuario(datos) {
  const response = await execute(
    'actualizar_usuario',
    'padron_licencias',
    [
      { nombre: 'p_usuario', valor: datos.usuario, tipo: 'string' },
      { nombre: 'p_nombres', valor: datos.nombres.toUpperCase(), tipo: 'string' },
      { nombre: 'p_clave', valor: datos.clave || null, tipo: 'string' },
      { nombre: 'p_cvedepto', valor: parseInt(datos.cvedepto), tipo: 'integer' },
      { nombre: 'p_nivel', valor: datos.nivel, tipo: 'integer' },
      { nombre: 'p_capturo', valor: 'sistema', tipo: 'string' }
    ],
    'guadalajara',
    null,
    'comun'
  )
  return response.result[0]
}

// 7. Dar de baja usuario
async function darBajaUsuario(usuario) {
  const response = await execute(
    'dar_baja_usuario',
    'padron_licencias',
    [
      { nombre: 'p_usuario', valor: usuario, tipo: 'string' },
      { nombre: 'p_capturo', valor: 'sistema', tipo: 'string' }
    ],
    'guadalajara',
    null,
    'comun'
  )
  return response.result[0]
}
```

---

## Seguridad y Mejores Prácticas

### Seguridad de Contraseñas

✅ **Nunca** almacenes contraseñas en texto plano
✅ **Siempre** usa los SPs para crear/actualizar usuarios (hasheo automático)
✅ Las contraseñas se hashean con **bcrypt** (factor 8)
✅ Cada hash tiene un **salt único** generado automáticamente

### Validación de Datos

```javascript
// CORRECTO: Validar antes de enviar
function validarDatosUsuario(datos) {
  if (!datos.usuario || datos.usuario.trim().length < 3) {
    throw new Error('Usuario debe tener al menos 3 caracteres')
  }

  if (!datos.nombres || datos.nombres.trim().length < 5) {
    throw new Error('Nombre completo debe tener al menos 5 caracteres')
  }

  if (!datos.clave || datos.clave.length < 6) {
    throw new Error('Contraseña debe tener al menos 6 caracteres')
  }

  if (![1, 5, 9, 10].includes(datos.nivel)) {
    throw new Error('Nivel inválido')
  }

  return true
}
```

### Manejo de Errores

```javascript
// CORRECTO: Manejar respuestas de error
async function crearUsuarioSeguro(datos) {
  try {
    const resultado = await crearUsuario(datos)

    if (!resultado.success) {
      // Error de negocio (usuario duplicado, etc.)
      console.error('Error de negocio:', resultado.message)
      return { ok: false, error: resultado.message }
    }

    // Éxito
    return { ok: true, mensaje: resultado.message }

  } catch (error) {
    // Error técnico (red, BD, etc.)
    console.error('Error técnico:', error)
    return { ok: false, error: 'Error de conexión' }
  }
}
```

### Niveles de Usuario

```javascript
const NIVELES_USUARIO = {
  BASICO: 1,        // Acceso básico de consulta
  INTERMEDIO: 5,    // Puede crear y editar
  AVANZADO: 9,      // Puede aprobar y validar
  ADMINISTRADOR: 10 // Acceso total al sistema
}

// Uso
await crearUsuario({
  usuario: 'jperez',
  nombres: 'Juan Perez',
  clave: 'password123',
  cvedepto: 5,
  nivel: NIVELES_USUARIO.INTERMEDIO,
  capturo: 'admin'
})
```

---

## Troubleshooting

### Error: "function crypt does not exist"

**Causa:** La extensión pgcrypto no está habilitada.

**Solución:**
```sql
CREATE EXTENSION IF NOT EXISTS pgcrypto;
```

### Error: "El departamento especificado no existe"

**Causa:** El cvedepto proporcionado no existe en comun.deptos.

**Solución:**
```sql
-- Verificar departamentos disponibles
SELECT * FROM comun.get_deptos_by_dependencia(1);
```

### Error: "El nivel debe ser 1, 5, 9 o 10"

**Causa:** Se intentó usar un nivel inválido.

**Solución:**
```javascript
// Solo usar valores permitidos
const nivelesValidos = [1, 5, 9, 10]
```

### Búsqueda no encuentra resultados

**Causa:** Posibles problemas:
1. Case-sensitivity incorrecta
2. Usuario dado de baja

**Solución:**
```javascript
// Las búsquedas son case-insensitive
// "jperez" = "JPEREZ" = "JPerez"

// Verificar si está dado de baja
const usuarios = await buscarUsuario('jperez')
if (usuarios.length > 0 && usuarios[0].fecbaj !== null) {
  console.log('Usuario dado de baja el:', usuarios[0].fecbaj)
}
```

### No se puede actualizar contraseña

**Causa:** Se está pasando un string vacío en lugar de NULL.

**Solución:**
```javascript
// INCORRECTO
p_clave: ''

// CORRECTO para mantener contraseña actual
p_clave: null

// CORRECTO para cambiar contraseña
p_clave: 'nuevaPassword123'
```

---

## Referencia Rápida - Tabla de Resumen

| # | Stored Procedure | Tipo | Parámetros | Uso Principal |
|---|-----------------|------|------------|---------------|
| 1 | get_all_usuarios | Consulta | 0 | Listar todos los usuarios |
| 2 | consulta_usuario_por_usuario | Consulta | 1 | Buscar por username |
| 3 | consulta_usuario_por_nombre | Consulta | 1 | Buscar por nombre |
| 4 | consulta_usuario_por_depto | Consulta | 2 | Buscar por departamento |
| 5 | get_dependencias | Catálogo | 0 | Combo dependencias |
| 6 | get_deptos_by_dependencia | Catálogo | 1 | Combo departamentos |
| 7 | crear_usuario | CRUD | 6 | Crear nuevo usuario |
| 8 | actualizar_usuario | CRUD | 6 | Actualizar usuario |
| 9 | dar_baja_usuario | CRUD | 2 | Dar de baja |

---

## Contacto y Soporte

Para más información sobre este módulo, consulta:
- Archivo de implementación: `CONSULTAUSUARIOS_all_procedures_IMPLEMENTED.sql`
- Script de deployment: `DEPLOY_CONSULTAUSUARIOS_2025-11-20.sql`
- Componente Vue: `consultausuariosfrm.vue`

---

**Fecha de Documentación:** 2025-11-20
**Versión:** 1.0
**Estado:** PRODUCCIÓN
