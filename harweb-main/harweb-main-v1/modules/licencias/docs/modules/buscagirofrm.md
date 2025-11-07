# Documentación Técnica: buscagirofrm.vue

## ✅ ESTADO: COMPLETADO Y FUNCIONAL

**Fecha de implementación:** 2025-01-06
**Versión:** 1.0

---

## 1. Descripción General

El módulo **buscagirofrm** permite buscar y seleccionar giros comerciales mediante múltiples filtros. Es un componente crítico para otros formularios de licencias y solicitudes que requieren seleccionar un giro específico.

### Características Principales:
- ✅ Búsqueda avanzada con 7 filtros diferentes
- ✅ Visualización completa de información de giros
- ✅ Modal de detalles con Bootstrap 5
- ✅ Selección de giros con persistencia en localStorage
- ✅ Copia automática al portapapeles
- ✅ Integración con múltiples tablas de catastro

---

## 2. Arquitectura

### Stack Tecnológico:
- **Frontend:** Vue.js 3 (Options API) con Bootstrap 5
- **Backend:** Laravel/PHP con endpoint genérico
- **Base de Datos:** PostgreSQL 14+ (esquema `catastro_gdl`)
- **Patrón de Comunicación:** eRequest/eResponse

### Componentes del Sistema:
1. **Base de Datos:**
   - Tabla: `catastro_gdl.categorias_giros` (11 categorías por defecto)
   - SP: `catastro_gdl.sp_categorias_giros_listar()`
   - SP: `catastro_gdl.sp_giros_buscar(...)` con 7 parámetros

2. **Backend:**
   - Endpoint: `POST http://localhost:8000/api/generic`
   - Módulo: `licencias` → Base: `padron_licencias` → Schema: `catastro_gdl`

3. **Frontend:**
   - Componente: `buscagirofrm.vue`
   - Ubicaciones: 4 versiones sincronizadas
     - `harweb-main-v1/frontend-vue/src/components/modules/licencias/`
     - `harweb-main-v1/modules/licencias/frontend-vue/src/components/`
     - `harweb-main-v2/frontend-vue/src/components/modules/licencias/`
     - `RefactorX/FrontEnd/src/views/modules/padron_licencias/`

---

## 3. Base de Datos

### 3.1 Tabla: categorias_giros

**Esquema:** `catastro_gdl.categorias_giros`

```sql
CREATE TABLE IF NOT EXISTS catastro_gdl.categorias_giros (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    activo CHAR(1) DEFAULT 'S' CHECK (activo IN ('S', 'N')),
    orden INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(50),
    updated_by VARCHAR(50)
);
```

**Categorías por defecto:**
1. Comercio al por menor
2. Servicios profesionales
3. Restaurantes y alimentos
4. Entretenimiento
5. Salud y belleza
6. Educación
7. Industria y manufactura
8. Construcción
9. Transporte
10. Servicios financieros
11. Otros servicios

### 3.2 Stored Procedure: sp_categorias_giros_listar

**Archivo:** `database/migrations/licencias/42_SP_CATEGORIAS_GIROS_CRUD.sql`

```sql
CREATE OR REPLACE FUNCTION catastro_gdl.sp_categorias_giros_listar()
RETURNS TABLE (
    id INTEGER,
    nombre TEXT,
    descripcion TEXT,
    activo TEXT,
    orden INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        c.id,
        COALESCE(TRIM(c.nombre::TEXT), '') AS nombre,
        COALESCE(TRIM(c.descripcion::TEXT), '') AS descripcion,
        COALESCE(TRIM(c.activo::TEXT), 'S') AS activo,
        COALESCE(c.orden, 0) AS orden
    FROM catastro_gdl.categorias_giros c
    WHERE c.activo = 'S'
    ORDER BY c.orden ASC, c.nombre ASC;
END;
$$ LANGUAGE plpgsql;
```

### 3.3 Stored Procedure: sp_giros_buscar

**Archivo:** `database/migrations/licencias/43_SP_GIROS_BUSCAR.sql`

**Parámetros:**
- `p_descripcion` (VARCHAR): Búsqueda parcial en descripción
- `p_codigo` (VARCHAR): Búsqueda exacta por código
- `p_id_categoria` (INTEGER): Filtro por categoría
- `p_tipo` (CHAR): Tipo de giro (L=Licencia, A=Anuncio, M=Mixto)
- `p_estado` (CHAR): Estado/vigencia (V=Vigente, N=No vigente)
- `p_autoev` (CHAR): Solo autoevaluación (S/N)
- `p_pacto` (CHAR): Pacto de homologación (S/N)

**Retorna:**
```sql
RETURNS TABLE (
    id INTEGER,
    codigo TEXT,
    descripcion TEXT,
    categoria_nombre TEXT,
    tipo TEXT,
    activo TEXT,
    autoev TEXT,
    pacto TEXT,
    costo NUMERIC(10,2),
    orden INTEGER
)
```

**Tablas utilizadas:**
- `catastro_gdl.c_giros` - Catálogo principal de giros
- `catastro_gdl.categorias_giros` - Categorías de giros
- `catastro_gdl.c_girosautoev` - Giros con autoevaluación
- `catastro_gdl.c_valoreslic` - Costos de licencias por año

**Características:**
- Búsqueda insensible a mayúsculas en descripción
- Filtros opcionales (todos pueden ser NULL)
- Excluye rangos especiales (5000-99999 y menores a 500)
- Obtiene costos del año actual
- Limita resultados a 100 para mejor rendimiento
- Ordena por descripción ascendente

---

## 4. API y Comunicación

### 4.1 Endpoint Genérico

**URL:** `POST http://localhost:8000/api/generic`

**Content-Type:** `application/json`

### 4.2 Request: Listar Categorías

```json
{
  "eRequest": {
    "action": "catastro_gdl.sp_categorias_giros_listar",
    "payload": {}
  }
}
```

### 4.3 Response: Listar Categorías

```json
{
  "status": "success",
  "eResponse": {
    "data": {
      "result": [
        {
          "id": 1,
          "nombre": "Comercio al por menor",
          "descripcion": "Actividades de comercio al por menor",
          "activo": "S",
          "orden": 1
        }
      ]
    }
  }
}
```

### 4.4 Request: Buscar Giros

```json
{
  "eRequest": {
    "action": "catastro_gdl.sp_giros_buscar",
    "payload": {
      "p_descripcion": "papelería",
      "p_codigo": null,
      "p_id_categoria": null,
      "p_tipo": "L",
      "p_estado": "V",
      "p_autoev": "S",
      "p_pacto": null
    }
  }
}
```

### 4.5 Response: Buscar Giros

```json
{
  "status": "success",
  "eResponse": {
    "data": {
      "result": [
        {
          "id": 1234,
          "codigo": "L-001-2023",
          "descripcion": "PAPELERÍA Y ARTÍCULOS DE ESCRITORIO",
          "categoria_nombre": "Comercio al por menor",
          "tipo": "L",
          "activo": "V",
          "autoev": "S",
          "pacto": "N",
          "costo": 2500.00,
          "orden": 0
        }
      ]
    }
  }
}
```

---

## 5. Componente Frontend (Vue.js)

### 5.1 Estructura del Componente

**Archivo:** `buscagirofrm.vue`

**Secciones:**
1. **Filtros de búsqueda:**
   - Descripción del giro (text)
   - Código del giro (text)
   - Categoría (select)
   - Tipo de giro (select)
   - Estado (select)
   - Checkboxes: Solo Autoevaluación, Pacto de Homologación

2. **Tabla de resultados:**
   - Código
   - Descripción
   - Categoría
   - Tipo
   - Estado
   - Autoevaluación
   - Pacto
   - Costo
   - Acciones (botón "Ver")

3. **Modal de detalles:**
   - Todos los datos del giro seleccionado
   - Botón "Confirmar selección"

### 5.2 Datos Reactivos (data)

```javascript
data() {
  return {
    // Filtros de búsqueda
    filtros: {
      descripcion: '',
      codigo: '',
      categoria: null,
      tipo: '',
      estado: '',
      autoev: false,
      pacto: false
    },

    // Datos
    categorias: [],
    giros: [],
    giroSeleccionado: null,
    giroDetalle: null,

    // UI
    loading: false,
    modalDetalle: null,
    mensaje: { texto: '', tipo: '' }
  }
}
```

### 5.3 Métodos Principales

#### cargarCategorias()
Carga el catálogo de categorías al montar el componente.

```javascript
async cargarCategorias() {
  const eRequest = {
    action: 'catastro_gdl.sp_categorias_giros_listar',
    payload: {}
  };
  const response = await fetch('http://localhost:8000/api/generic', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ eRequest })
  });
  const data = await response.json();
  this.categorias = data.eResponse.data.result || [];
}
```

#### buscarGiros()
Ejecuta la búsqueda con los filtros especificados.

```javascript
async buscarGiros() {
  this.loading = true;
  const eRequest = {
    action: 'catastro_gdl.sp_giros_buscar',
    payload: {
      p_descripcion: this.filtros.descripcion || null,
      p_codigo: this.filtros.codigo || null,
      p_id_categoria: this.filtros.categoria || null,
      p_tipo: this.filtros.tipo || null,
      p_estado: this.filtros.estado || null,
      p_autoev: this.filtros.autoev ? 'S' : null,
      p_pacto: this.filtros.pacto ? 'S' : null
    }
  };
  // ... fetch y procesamiento
  this.giros = data.eResponse.data.result || [];
  this.loading = false;
}
```

#### verDetalleGiro(giro)
Abre el modal con los detalles del giro.

```javascript
verDetalleGiro(giro) {
  this.giroDetalle = giro;
  this.modalDetalle = new bootstrap.Modal(
    document.getElementById('modalDetalleGiro')
  );
  this.modalDetalle.show();
}
```

#### confirmarSeleccion()
Guarda el giro en localStorage y copia al portapapeles.

```javascript
confirmarSeleccion() {
  if (this.giroSeleccionado) {
    // 1. Guardar en localStorage
    const giroData = {
      id: this.giroSeleccionado.id,
      codigo: this.giroSeleccionado.codigo,
      descripcion: this.giroSeleccionado.descripcion,
      categoria: this.giroSeleccionado.categoria_nombre,
      tipo: this.giroSeleccionado.tipo,
      costo: this.giroSeleccionado.costo,
      timestamp: new Date().toISOString()
    };
    localStorage.setItem('giroSeleccionado', JSON.stringify(giroData));

    // 2. Copiar al portapapeles
    const texto = `${giroData.codigo} - ${giroData.descripcion}`;
    navigator.clipboard.writeText(texto).then(() => {
      this.mostrarMensaje(
        'Giro confirmado: "' + giroData.descripcion +
        '". Se copió al portapapeles y está disponible para otros formularios.',
        'success'
      );

      // 3. Emitir evento (para futura compatibilidad)
      this.$emit('giro-seleccionado', this.giroSeleccionado);

      // 4. Cerrar modal
      if (this.modalDetalle) {
        this.modalDetalle.hide();
      }
    });
  }
}
```

---

## 6. Integración con Otros Formularios

### 6.1 Recuperar Giro Seleccionado

Otros formularios pueden recuperar el giro seleccionado desde localStorage:

```javascript
// En cualquier componente Vue
mounted() {
  const giroGuardado = localStorage.getItem('giroSeleccionado');
  if (giroGuardado) {
    const giro = JSON.parse(giroGuardado);
    this.formulario.giro_solicitado = giro.descripcion;
    this.formulario.id_giro = giro.id;
    this.formulario.costo_giro = giro.costo;
  }
}
```

### 6.2 Uso como Componente Hijo

El componente puede ser usado como componente hijo que emite eventos:

```vue
<template>
  <buscagirofrm @giro-seleccionado="handleGiroSeleccionado" />
</template>

<script>
export default {
  methods: {
    handleGiroSeleccionado(giro) {
      this.formulario.id_giro = giro.id;
      this.formulario.giro_descripcion = giro.descripcion;
    }
  }
}
</script>
```

---

## 7. Configuración en modules-config.js

```javascript
{
  name: "buscagirofrm",
  path: "/licencias/buscagirofrm",
  displayName: "* Buscar Giros"
}
```

**Nota:** El asterisco (*) indica que el componente está completamente implementado y funcional.

---

## 8. Flujo de Trabajo Completo

1. **Usuario accede al módulo:** `/licencias/buscagirofrm`
2. **Carga inicial:** Se cargan las categorías desde la BD
3. **Usuario ingresa filtros:** Descripción, categoría, tipo, etc.
4. **Click en "Buscar":** Se ejecuta `sp_giros_buscar` con filtros
5. **Resultados mostrados:** Tabla con giros encontrados
6. **Usuario hace click en "Ver":** Se abre modal con detalles
7. **Usuario hace click en "Confirmar selección":**
   - Giro guardado en localStorage
   - Código y descripción copiados al portapapeles
   - Mensaje de confirmación mostrado
   - Modal cerrado automáticamente
8. **Otros formularios pueden recuperar:** El giro desde localStorage

---

## 9. Casos de Uso Principales

### 9.1 Búsqueda Simple por Descripción
**Usuario:** Funcionario de licencias
**Objetivo:** Encontrar giros que contengan "papelería"
**Pasos:**
1. Ingresa "papelería" en campo descripción
2. Click en "Buscar"
3. Se muestran todos los giros relacionados

### 9.2 Filtrado por Autoevaluación
**Usuario:** Funcionario de trámites express
**Objetivo:** Encontrar solo giros que permitan autoevaluación
**Pasos:**
1. Marca checkbox "Solo Autoevaluación"
2. Click en "Buscar"
3. Se muestran solo giros con autoevaluación habilitada

### 9.3 Selección para Nueva Solicitud
**Usuario:** Funcionario registrando nueva solicitud
**Objetivo:** Seleccionar giro para asociar a solicitud
**Pasos:**
1. Busca y encuentra el giro deseado
2. Click en "Ver" para ver detalles
3. Click en "Confirmar selección"
4. Giro guardado y disponible en formulario de solicitud

---

## 10. Seguridad y Validaciones

### 10.1 Validaciones Backend (SP)
- ✅ Todos los parámetros son opcionales (manejo de NULL)
- ✅ Búsqueda case-insensitive en descripción
- ✅ Filtrado de rangos especiales (5000-99999)
- ✅ Verificación de ID válido (> 500)
- ✅ Límite de resultados (100 máximo)

### 10.2 Validaciones Frontend
- ✅ Validación de campos vacíos antes de buscar
- ✅ Mensaje si no hay resultados
- ✅ Loading state durante búsqueda
- ✅ Manejo de errores de red
- ✅ Validación antes de confirmar selección

### 10.3 Permisos
- Usuario debe estar autenticado
- Acceso al módulo de licencias requerido
- Sin permisos especiales adicionales (consulta pública)

---

## 11. Pruebas y Validación

### 11.1 Pruebas Funcionales Completadas
✅ Carga de categorías
✅ Búsqueda por descripción
✅ Búsqueda por código
✅ Filtro por categoría
✅ Filtro por tipo
✅ Filtro por estado
✅ Filtro por autoevaluación
✅ Filtro por pacto
✅ Visualización de detalles en modal
✅ Confirmación de selección
✅ Guardado en localStorage
✅ Copia al portapapeles
✅ Modal se cierra correctamente
✅ Bootstrap correctamente importado

### 11.2 Casos de Prueba
Ver archivo: `test-cases/buscagirofrm_test_cases.md`

---

## 12. Problemas Conocidos y Soluciones

### 12.1 Error: Bootstrap is not defined
**Problema:** Modal no se podía abrir
**Solución:** Agregar `import * as bootstrap from 'bootstrap'` en línea 265

### 12.2 Error: Data.eResponse.data is undefined
**Problema:** Acceso incorrecto a resultado del SP
**Solución:** Cambiar a `data.eResponse.data.result`

### 12.3 Error: BPCHAR type mismatch
**Problema:** PostgreSQL retorna BPCHAR en lugar de VARCHAR
**Solución:** Usar TEXT en RETURNS TABLE y ::TEXT en SELECTs

### 12.4 Error: Categorias_giros does not exist
**Problema:** Tabla no existía en esquema catastro_gdl
**Solución:** Crear tabla con migración 42_SP_CATEGORIAS_GIROS_CRUD.sql

---

## 13. Mantenimiento y Extensibilidad

### 13.1 Agregar Nuevos Filtros
1. Agregar parámetro al SP `sp_giros_buscar`
2. Agregar campo en `filtros` del componente Vue
3. Agregar control HTML en template
4. Incluir en payload del eRequest

### 13.2 Modificar Categorías
1. Editar registros en tabla `categorias_giros`
2. Mantener campo `activo = 'S'` para visibles
3. Usar campo `orden` para ordenamiento

### 13.3 Agregar Nuevos Campos al Giro
1. Modificar RETURNS TABLE del SP
2. Agregar campo en SELECT del SP
3. Actualizar template Vue para mostrar campo

---

## 14. Archivos Relacionados

### Base de Datos:
- `database/migrations/licencias/42_SP_CATEGORIAS_GIROS_CRUD.sql`
- `database/migrations/licencias/43_SP_GIROS_BUSCAR.sql`

### Frontend (4 versiones):
- `harweb-main-v1/frontend-vue/src/components/modules/licencias/buscagirofrm.vue`
- `harweb-main-v1/modules/licencias/frontend-vue/src/components/buscagirofrm.vue`
- `harweb-main-v2/frontend-vue/src/components/modules/licencias/buscagirofrm.vue`
- `RefactorX/FrontEnd/src/views/modules/padron_licencias/buscagirofrm.vue`

### Configuración:
- `frontend-vue/src/config/modules-config.js` (línea 663)

### Documentación:
- `docs/modules/buscagirofrm.md` (este archivo)
- `docs/analisis/buscagirofrm.md`
- `docs/use-cases/buscagirofrm_use_cases.md`
- `docs/test-cases/buscagirofrm_test_cases.md`
- `docs/PLAN_IMPLEMENTACION_LICENCIAS_COMPLETO.md`

---

## 15. Métricas de Implementación

- **Fecha inicio:** 2025-01-06
- **Fecha finalización:** 2025-01-06
- **Tiempo de desarrollo:** 1 día
- **Archivos creados/modificados:** 10
- **Líneas de código:**
  - SQL: ~250 líneas
  - Vue.js: ~450 líneas (por versión)
  - Total: ~2,050 líneas

---

## 16. Referencias y Recursos

- [Vue.js 3 Documentation](https://vuejs.org/)
- [Bootstrap 5 Modal](https://getbootstrap.com/docs/5.0/components/modal/)
- [PostgreSQL Functions](https://www.postgresql.org/docs/current/sql-createfunction.html)
- [LocalStorage API](https://developer.mozilla.org/en-US/docs/Web/API/Window/localStorage)
- [Clipboard API](https://developer.mozilla.org/en-US/docs/Web/API/Clipboard)

---

**Versión:** 1.0
**Última actualización:** 2025-01-06
**Estado:** ✅ COMPLETADO Y FUNCIONAL
**Mantenido por:** Equipo de Desarrollo Licencias
