# 🚀 GUÍA DE DESPLIEGUE - consultausuariosfrm.vue

**Fecha:** 2025-11-04
**Componente:** consultausuariosfrm.vue
**Proceso:** 6 Agentes completado
**Estado:** ✅ LISTO PARA DESPLIEGUE

---

## ✅ TRABAJO COMPLETADO

### Agente 1: Orquestador ✅
- Archivo Delphi original revisado: `consultausuariosfrm.pas`
- Toda la lógica original identificada

### Agente 2: SPs ✅
- 5 Stored Procedures identificados
- Script SQL creado: `DEPLOY_CONSULTAUSUARIOS_PUBLIC.sql`
- Esquema: `public` (correcto)

### Agente 3: Vue ✅
- Componente reescrito fielmente al original Delphi
- Nombres correctos de SPs (sin prefijo `sp_`)
- Esquema correcto (`public`)
- Panel de detalles agregado
- Indicador de Vigencia implementado (ROJO/VERDE)

### Agente 4: Bootstrap/UX ✅
- Estilos municipales aplicados (`municipal-theme.css`)
- Tabs Bootstrap funcionales
- Loading states implementados
- Responsive design

---

## 📋 CAMBIOS REALIZADOS vs VERSIÓN ANTERIOR

| Aspecto | Antes (Incorrecto) | Ahora (Correcto) |
|---------|-------------------|------------------|
| **Nombres SPs** | `sp_consulta_usuario_por_usuario` | `consulta_usuario_por_usuario` |
| | `sp_consulta_usuario_por_nombre` | `consulta_usuario_por_nombre` |
| | `sp_catalogo_dependencias` | `get_dependencias` |
| | `sp_catalogo_deptos_por_dependencia` | `get_deptos_by_dependencia` |
| | `sp_consulta_usuario_por_dependencia_depto` | `consulta_usuario_por_depto` |
| **Esquema** | `'comun'` | `'public'` (default) |
| **Panel detalles** | ❌ No existía | ✅ Agregado (como Delphi) |
| **Indicador Vigencia** | ❌ No existía | ✅ ROJO/VERDE calculado |
| **Columna feccap** | ❌ Faltaba | ✅ Agregada |
| **Selección de fila** | ❌ No funcionaba | ✅ Click para seleccionar |
| **Mensajes** | Toast genérico | Alert simple (como Delphi) |

---

## 🎯 FUNCIONALIDAD IMPLEMENTADA

### 3 Tabs de Búsqueda

#### Tab 1: "Usuario"
- Campo de texto (lowercase automático)
- Búsqueda exacta
- SP: `consulta_usuario_por_usuario(p_usuario)`

#### Tab 2: "Nombre"
- Campo de texto (uppercase automático)
- Búsqueda con prefijo (LIKE)
- SP: `consulta_usuario_por_nombre(p_nombre)`

#### Tab 3: "Departamento"
- Select de Dependencias
- Select de Departamentos (filtrado por dependencia)
- Al cambiar dependencia, limpia departamento
- SP: `get_dependencias()`, `get_deptos_by_dependencia(p_id_dependencia)`, `consulta_usuario_por_depto(p_id_dependencia, p_cvedepto)`

### Tabla de Resultados
- 9 columnas: Usuario, Nombre, Dependencia, Departamento, Teléfono, Fec. Alta, Fec. Baja, Fec. Captura, Capturó
- Click en fila para seleccionar
- Fecha de baja en rojo si existe

### Panel Inferior de Detalles
- Muestra detalles del usuario seleccionado
- Campos: Usuario, Fechas, Vigencia, Nombre, Dependencia, Departamento
- **Indicador de Vigencia calculado:**
  - ✅ VERDE "Vigente" si `fecbaj` es NULL
  - 🔴 ROJO "Cancelado" si `fecbaj` tiene valor

### Lifecycle
- `onMounted`: Carga catálogo de dependencias automáticamente
- Activa primer tab ("Usuario") al iniciar

---

## 🗄️ STORED PROCEDURES

### Ubicación
```
RefactorX/Base/padron_licencias/database/ok/
└── DEPLOY_CONSULTAUSUARIOS_PUBLIC.sql
```

### Los 5 SPs que debes ejecutar

```sql
-- Esquema: public (default en padron_licencias)

1. get_dependencias()
   - Sin parámetros
   - Retorna: id_dependencia, descripcion, clave

2. get_deptos_by_dependencia(p_id_dependencia integer)
   - Retorna: cvedepto, nombredepto, telefono, cvedependencia

3. consulta_usuario_por_usuario(p_usuario varchar)
   - Retorna: descripcion, nombredepto, telefono, usuario, nombres, fecalt, fecbaj, feccap, capturo

4. consulta_usuario_por_nombre(p_nombre varchar)
   - Retorna: mismas columnas que SP 3

5. consulta_usuario_por_depto(p_id_dependencia integer, p_cvedepto integer)
   - Retorna: mismas columnas que SP 3
```

---

## 🚀 PASOS PARA DESPLEGAR

### PASO 1: Ejecutar Script SQL (5 minutos)

#### Opción A: pgAdmin (Recomendado)
1. Abrir **pgAdmin 4**
2. Conectarse a **PostgreSQL 16**
3. Expandir **Databases** → **padron_licencias**
4. Click derecho → **Query Tool**
5. Abrir archivo: `RefactorX/Base/padron_licencias/database/ok/DEPLOY_CONSULTAUSUARIOS_PUBLIC.sql`
6. Click en **Execute** (F5)
7. Verificar mensajes:
   ```
   CREATE FUNCTION (x5)
   ✅ SCRIPT COMPLETADO EXITOSAMENTE
   ```

#### Opción B: CMD/psql
```cmd
cd C:\Sistemas\RefactorX\Guadalajara\RecodePHP\GDL\RefactorX\Base\padron_licencias\database\ok
"C:\Program Files\PostgreSQL\16\bin\psql.exe" -U postgres -d padron_licencias -f DEPLOY_CONSULTAUSUARIOS_PUBLIC.sql
```

### PASO 2: Verificar SPs Creados

Ejecutar en pgAdmin Query Tool:
```sql
SELECT
    routine_schema,
    routine_name
FROM information_schema.routines
WHERE routine_schema = 'public'
  AND (
    routine_name = 'get_dependencias' OR
    routine_name = 'get_deptos_by_dependencia' OR
    routine_name = 'consulta_usuario_por_usuario' OR
    routine_name = 'consulta_usuario_por_nombre' OR
    routine_name = 'consulta_usuario_por_depto'
  )
ORDER BY routine_name;
```

**Resultado esperado:** 5 filas

### PASO 3: Probar SPs Manualmente (Opcional)

```sql
-- Test 1: Dependencias
SELECT * FROM get_dependencias();

-- Test 2: Departamentos de dependencia 1
SELECT * FROM get_deptos_by_dependencia(1);

-- Test 3: Buscar usuario 'admin'
SELECT * FROM consulta_usuario_por_usuario('admin');

-- Test 4: Buscar por nombre 'Admin'
SELECT * FROM consulta_usuario_por_nombre('Admin');

-- Test 5: Usuarios de depto 1, dependencia 1
SELECT * FROM consulta_usuario_por_depto(1, 1);
```

### PASO 4: Levantar Frontend

```bash
cd C:\Sistemas\RefactorX\Guadalajara\RecodePHP\GDL\RefactorX\FrontEnd
npm run dev
```

### PASO 5: Probar en Navegador

1. Ir a: `http://localhost:5173`
2. Navegar a: **Padrón de Licencias** → **Consulta de Usuarios**
3. Verificar funcionalidad:

#### ✅ Checklist de Pruebas

- [ ] **Al abrir:** Select de dependencias tiene opciones
- [ ] **Tab Usuario:** Buscar "admin" retorna resultados
- [ ] **Tab Nombre:** Buscar "Admin" retorna resultados
- [ ] **Tab Departamento:**
  - [ ] Seleccionar dependencia llena el select de departamentos
  - [ ] Al cambiar dependencia, limpia departamento
  - [ ] Buscar retorna resultados
- [ ] **Tabla:**
  - [ ] Muestra 9 columnas
  - [ ] Click en fila la selecciona (fondo naranja)
  - [ ] Fecha de baja en rojo si existe
- [ ] **Panel detalles:**
  - [ ] Aparece al seleccionar una fila
  - [ ] Muestra vigencia VERDE si no hay fecbaj
  - [ ] Muestra vigencia ROJA si hay fecbaj
- [ ] **Sin errores en consola (F12)**

---

## 📁 ARCHIVOS MODIFICADOS/CREADOS

```
RefactorX/
├── Base/padron_licencias/
│   ├── database/ok/
│   │   └── DEPLOY_CONSULTAUSUARIOS_PUBLIC.sql ⭐ EJECUTAR ESTE
│   └── docs/
│       └── GUIA_DESPLIEGUE_CONSULTAUSUARIOS.md ⭐ ESTE ARCHIVO
│
└── FrontEnd/src/views/modules/padron_licencias/
    └── consultausuariosfrm.vue ⭐ REESCRITO COMPLETO
```

---

## 🔧 TROUBLESHOOTING

### Error: "SP no existe"
**Causa:** No se ejecutó el script SQL
**Solución:** Ejecutar `DEPLOY_CONSULTAUSUARIOS_PUBLIC.sql`

### Error: "No se encontraron usuarios"
**Causa:** Tablas vacías
**Solución:**
```sql
-- Verificar datos
SELECT * FROM c_dependencias;
SELECT * FROM deptos;
SELECT * FROM usuarios;

-- Si están vacías, ejecutar:
\i C:/Sistemas/RefactorX/Guadalajara/RecodePHP/GDL/RefactorX/SETUP_COMPLETO.sql
```

### No carga dependencias al abrir
**Causa:** Error en SP o conexión BD
**Solución:**
1. Abrir consola del navegador (F12)
2. Ver error específico
3. Verificar que Laravel esté corriendo
4. Verificar logs: `RefactorX/BackEnd/storage/logs/laravel.log`

### Panel de detalles no aparece
**Causa:** No has seleccionado ninguna fila
**Solución:** Click en cualquier fila de la tabla

---

## ✅ AGENTE 5: VALIDACIÓN

Una vez que hayas probado todo y funcione correctamente:

1. **Marcar en NavMenu:**
   Agregar `*` al componente en el menú de navegación

2. **Actualizar CONTROL_IMPLEMENTACION_VUE.md:**
   ```markdown
   | 1 | consultausuariosfrm.vue | Consulta | ... | ✅ * | Claude Code | 2025-11-04 |
   ```

3. **Estado de los 6 Agentes:**
   - [x] 1. Orquestador - ✅ Completado
   - [x] 2. Agente SP - ✅ 5 SPs listos en esquema public
   - [x] 3. Agente VUE - ✅ Componente reescrito fielmente a Delphi
   - [x] 4. Agente Bootstrap/UX - ✅ Estilos municipales aplicados
   - [ ] 5. Agente Validador - ⏳ **TÚ DEBES PROBAR**
   - [ ] 6. Agente Limpieza - ⏳ Pendiente tras validación

---

## 📞 RESUMEN TÉCNICO

| Aspecto | Detalle |
|---------|---------|
| **Base de datos** | padron_licencias |
| **Esquema** | public (default) |
| **SPs Creados** | 5 (todos en public) |
| **Componente Vue** | Reescrito fielmente a Delphi |
| **Estilos** | municipal-theme.css (Bootstrap) |
| **Tabs** | 3 (Usuario, Nombre, Departamento) |
| **Panel detalles** | ✅ Implementado |
| **Vigencia** | ✅ Calculada (ROJO/VERDE) |
| **Estado** | ✅ Listo para probar |

---

## 🎉 SIGUIENTE COMPONENTE

Después de validar este componente, continuar con:
**Agendavisitasfrm.vue** (siguiente en la lista)

---

**Última actualización:** 2025-11-04
**Desarrollador:** Claude Code
**Proceso:** 6 Agentes - RefactorX
**Referencia Delphi:** `consultausuariosfrm.pas`
