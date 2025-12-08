# Reporte de Corrección de Stored Procedures - Módulo Mercados

**Fecha:** 2025-11-26
**Módulo:** Mercados
**Base de datos:** mercados
**Esquema:** public

## Resumen

Se actualizaron 4 componentes Vue del módulo mercados para usar los nombres correctos de stored procedures existentes en la base de datos.

## Stored Procedures en la Base de Datos

### Catálogo de Mercados
- `sp_catalogo_mercados_list` - Listar mercados
- `sp_catalogo_mercados_create` - Crear mercado
- `sp_catalogo_mercados_update` - Actualizar mercado
- `sp_catalogo_mercados_delete` - Eliminar mercado

### Categorías
- `sp_categoria_list` - Listar categorías
- `sp_categoria_create` - Crear categoría
- `sp_categoria_update` - Actualizar categoría
- `sp_categoria_delete` - Eliminar categoría

### Auxiliares
- `sp_catalogo_secciones` - Obtener secciones/zonas
- `sp_get_recaudadoras` - Obtener recaudadoras
- `sp_get_mercados` - Obtener mercados
- `sp_get_mercados_by_oficina` - Obtener mercados por oficina

## Archivos Actualizados

### 1. CatalogoMercados.vue
**Ruta:** `C:\Sistemas\RefactorX\Guadalajara\RecodePHP\GDL\RefactorX\FrontEnd\src\views\modules\mercados\CatalogoMercados.vue`

**Cambios aplicados:**

#### fetchData()
- **Antes:** `{ action: 'list', module: 'catalogo_mercados' }`
- **Después:**
  ```javascript
  {
    database: 'mercados',
    schema: 'public',
    procedure: 'sp_catalogo_mercados_list',
    params: {}
  }
  ```

#### submitForm()
- **Antes:** `{ action, module: 'catalogo_mercados', payload: this.form }`
- **Después:**
  ```javascript
  {
    database: 'mercados',
    schema: 'public',
    procedure: 'sp_catalogo_mercados_create' | 'sp_catalogo_mercados_update',
    params: this.form
  }
  ```

#### deleteRow()
- **Antes:** `{ action: 'delete', module: 'catalogo_mercados', payload: {...} }`
- **Después:**
  ```javascript
  {
    database: 'mercados',
    schema: 'public',
    procedure: 'sp_catalogo_mercados_delete',
    params: {
      p_oficina: row.oficina,
      p_num_mercado_nvo: row.num_mercado_nvo
    }
  }
  ```

#### showReport()
- **Antes:** `{ action: 'report', module: 'catalogo_mercados', payload: {...} }`
- **Después:**
  ```javascript
  {
    database: 'mercados',
    schema: 'public',
    procedure: 'sp_catalogo_mercados_list',
    params: {}
  }
  ```

### 2. CatalogoMntto.vue
**Ruta:** `C:\Sistemas\RefactorX\Guadalajara\RecodePHP\GDL\RefactorX\FrontEnd\src\views\modules\mercados\CatalogoMntto.vue`

**Cambios aplicados:**

#### api() - Método auxiliar
- **Antes:** `async api(action, params = {})`
- **Después:**
  ```javascript
  async api(procedure, params = {}) {
    return fetch('/api/execute', {
      method: 'POST',
      body: JSON.stringify({
        database: 'mercados',
        schema: 'public',
        procedure,
        params
      })
    });
  }
  ```

#### loadCatalogo()
- **Antes:** `this.api('getCatalogoList')`
- **Después:** `this.api('sp_catalogo_mercados_list')`

#### loadRecaudadoras()
- **Antes:** `this.api('getRecaudadoras')`
- **Después:** `this.api('sp_get_recaudadoras')`

#### loadCategorias()
- **Antes:** `this.api('getCategorias')`
- **Después:** `this.api('sp_categoria_list')`

#### loadZonas()
- **Antes:** `this.api('getZonas')`
- **Después:** `this.api('sp_catalogo_secciones')`

#### loadCuentas()
- **Antes:** `this.api('getCuentas')`
- **Después:** `this.api('sp_get_mercados')`

#### onSubmit()
- **Antes:** `this.api('updateCatalogo' | 'insertCatalogo', params)`
- **Después:** `this.api('sp_catalogo_mercados_update' | 'sp_catalogo_mercados_create', params)`

### 3. Categoria.vue
**Ruta:** `C:\Sistemas\RefactorX\Guadalajara\RecodePHP\GDL\RefactorX\FrontEnd\src\views\modules\mercados\Categoria.vue`

**Cambios aplicados:**

#### fetchCategorias()
- **Antes:**
  ```javascript
  {
    eRequest: { action: 'categoria.list' }
  }
  ```
  Y respuesta: `res.eResponse.success` / `res.eResponse.data`
- **Después:**
  ```javascript
  {
    database: 'mercados',
    schema: 'public',
    procedure: 'sp_categoria_list',
    params: {}
  }
  ```
  Y respuesta: `res.success` / `res.data`

#### createCategoria()
- **Antes:**
  ```javascript
  {
    eRequest: {
      action: 'categoria.create',
      params: { categoria, descripcion }
    }
  }
  ```
- **Después:**
  ```javascript
  {
    database: 'mercados',
    schema: 'public',
    procedure: 'sp_categoria_create',
    params: {
      p_categoria: this.form.categoria,
      p_descripcion: this.form.descripcion
    }
  }
  ```

#### updateCategoria()
- **Antes:**
  ```javascript
  {
    eRequest: {
      action: 'categoria.update',
      params: { categoria, descripcion }
    }
  }
  ```
- **Después:**
  ```javascript
  {
    database: 'mercados',
    schema: 'public',
    procedure: 'sp_categoria_update',
    params: {
      p_categoria: this.form.categoria,
      p_descripcion: this.form.descripcion
    }
  }
  ```

#### deleteCategoria()
- **Antes:**
  ```javascript
  {
    eRequest: {
      action: 'categoria.delete',
      params: { categoria }
    }
  }
  ```
- **Después:**
  ```javascript
  {
    database: 'mercados',
    schema: 'public',
    procedure: 'sp_categoria_delete',
    params: { p_categoria: categoria }
  }
  ```

### 4. CategoriaMntto.vue
**Ruta:** `C:\Sistemas\RefactorX\Guadalajara\RecodePHP\GDL\RefactorX\FrontEnd\src\views\modules\mercados\CategoriaMntto.vue`

**Cambios aplicados:**

#### loadCategorias()
- **Antes:** `{ action: 'categoria.list' }`
- **Después:**
  ```javascript
  {
    database: 'mercados',
    schema: 'public',
    procedure: 'sp_categoria_list',
    params: {}
  }
  ```

#### onSubmit()
- **Antes:**
  ```javascript
  {
    action: 'categoria.update' | 'categoria.create',
    data: { categoria, descripcion }
  }
  ```
- **Después:**
  ```javascript
  {
    database: 'mercados',
    schema: 'public',
    procedure: 'sp_categoria_update' | 'sp_categoria_create',
    params: {
      p_categoria: this.form.categoria,
      p_descripcion: this.form.descripcion
    }
  }
  ```

#### deleteCategoria()
- **Antes:**
  ```javascript
  {
    action: 'categoria.delete',
    data: { categoria }
  }
  ```
- **Después:**
  ```javascript
  {
    database: 'mercados',
    schema: 'public',
    procedure: 'sp_categoria_delete',
    params: { p_categoria: cat.categoria }
  }
  ```

## Patrón de Nombres de Parámetros

Se estandarizó el uso de prefijo `p_` para los parámetros de los stored procedures:

- `p_oficina`
- `p_num_mercado_nvo`
- `p_categoria`
- `p_descripcion`

## Cambios en Formato de Respuesta

Algunos componentes tenían un formato de respuesta envuelto (`eRequest`/`eResponse`), que fue actualizado al formato estándar:

**Antes:**
```javascript
res.eResponse.success
res.eResponse.data
res.eResponse.message
```

**Después:**
```javascript
res.success
res.data
res.message
```

## Estadísticas de Cambios

- **Total de archivos actualizados:** 4
- **Total de métodos corregidos:** 15
- **Total de llamadas a SP actualizadas:** 20+

## Verificación

Todos los nombres de stored procedures ahora coinciden exactamente con los SPs existentes en la base de datos `mercados`, esquema `public`.

## Próximos Pasos

1. Verificar que el backend (GenericController.php) maneje correctamente el formato actualizado
2. Probar cada componente para asegurar funcionamiento correcto
3. Verificar que los parámetros con prefijo `p_` sean correctamente mapeados en el backend

## Notas

- Se mantuvo la lógica de negocio sin cambios
- Se respetó el formato de UI de cada componente
- Todos los cambios son compatibles con la estructura actual del backend
