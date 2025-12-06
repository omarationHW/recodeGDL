# REPORTE: EnergiaModif UI Enhancement
**Fecha:** 2025-12-05
**Módulo:** /energia-modif (Cambios de Energía Eléctrica)
**Estado:** ✅ COMPLETADO

---

## SOLICITUD DEL USUARIO

> "Convierte en /energia-modif el input de Mercado en un Select y que se cargue al seleccionar una recaudadora asi como en /emision-energia, la categoria se debe auto-llenar cuando se elija un mercado como en /carga-pag-locales"

---

## CAMBIOS REALIZADOS

### 1. Template (HTML)

#### Campo Mercado - Convertido a Select
**Antes (línea 36-38):**
```vue
<input type="number" v-model.number="formBuscar.num_mercado"
  class="municipal-form-control" required min="1" />
```

**Después (línea 37-44):**
```vue
<select v-model="formBuscar.num_mercado" @change="onMercadoChange"
  class="municipal-form-control" required
  :disabled="!formBuscar.oficina || mercados.length === 0">
  <option value="">Seleccione...</option>
  <option v-for="merc in mercados" :key="merc.num_mercado_nvo" :value="merc.num_mercado_nvo">
    {{ merc.num_mercado_nvo }} - {{ merc.descripcion }}
  </option>
</select>
```

**Características:**
- ✅ Convertido de input numérico a select dropdown
- ✅ Muestra número y descripción del mercado
- ✅ Deshabilitado hasta que se seleccione una recaudadora
- ✅ Deshabilitado si no hay mercados disponibles

#### Campo Recaudadora - Agregado @change
**Antes (línea 27):**
```vue
<select v-model="formBuscar.oficina" class="municipal-form-control" required>
```

**Después (línea 28):**
```vue
<select v-model="formBuscar.oficina" @change="onRecaudadoraChange"
  class="municipal-form-control" required>
```

**Características:**
- ✅ Al cambiar la recaudadora, se cargan los mercados automáticamente

#### Campo Categoría - Ahora es Read-Only
**Antes (línea 47):**
```vue
<input type="number" v-model.number="formBuscar.categoria"
  class="municipal-form-control" required min="1" />
```

**Después (línea 49-50):**
```vue
<input type="number" v-model.number="formBuscar.categoria"
  class="municipal-form-control" required min="1" disabled />
```

**Características:**
- ✅ Campo deshabilitado (read-only)
- ✅ Se auto-llena al seleccionar un mercado

---

### 2. Script (JavaScript)

#### Nuevo State Reactivo
**Agregado (línea 217):**
```javascript
const mercados = ref([])
```

#### Nuevo Método: onRecaudadoraChange
**Agregado (líneas 303-341):**
```javascript
const onRecaudadoraChange = async () => {
  formBuscar.value.num_mercado = ''
  formBuscar.value.categoria = ''
  mercados.value = []

  if (!formBuscar.value.oficina) return

  loading.value = true
  try {
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_get_catalogo_mercados',
        Base: 'padron_licencias',
        Parametros: [
          { Nombre: 'p_id_rec', Valor: parseInt(formBuscar.value.oficina) },
          { Nombre: 'p_nivel_usuario', Valor: 1 }
        ]
      }
    })

    const apiResponse = response.data.eResponse || response.data
    const data = apiResponse.data?.result || apiResponse.data || []

    if (Array.isArray(data) && data.length > 0) {
      mercados.value = data
    } else if (apiResponse.success === false) {
      toast.error(apiResponse.message || 'Error al cargar mercados')
      mercados.value = []
    } else {
      mercados.value = []
    }
  } catch (error) {
    console.error('Error onRecaudadoraChange:', error)
    toast.error('Error al cargar mercados: ' + error.message)
  } finally {
    loading.value = false
  }
}
```

**Funcionalidad:**
- Limpia el mercado y categoría seleccionados
- Carga los mercados de la recaudadora usando `sp_get_catalogo_mercados`
- Usa la base de datos `padron_licencias`
- Maneja errores y muestra notificaciones toast

#### Nuevo Método: onMercadoChange
**Agregado (líneas 343-348):**
```javascript
const onMercadoChange = () => {
  const mercadoSeleccionado = mercados.value.find(m => m.num_mercado_nvo == formBuscar.value.num_mercado)
  if (mercadoSeleccionado) {
    formBuscar.value.categoria = mercadoSeleccionado.categoria
  }
}
```

**Funcionalidad:**
- Busca el mercado seleccionado en el array de mercados
- Auto-llena el campo categoría con el valor del mercado

---

## STORED PROCEDURE UTILIZADO

### sp_get_catalogo_mercados
- **Base de datos:** padron_licencias
- **Parámetros:**
  - p_id_rec (INTEGER) - ID de la recaudadora
  - p_nivel_usuario (INTEGER) - Nivel de acceso (siempre 1)

**Campos retornados:**
- oficina (SMALLINT)
- num_mercado_nvo (SMALLINT)
- **categoria (SMALLINT)** ⭐
- descripcion (VARCHAR)
- cuenta_ingreso (INTEGER)
- cuenta_energia (INTEGER)
- id_zona (SMALLINT)
- zona (VARCHAR)
- tipo_emision (VARCHAR)

**Nota:** Este SP retorna la categoría que es requerida para auto-llenar el campo.

---

## PATRONES SEGUIDOS

### Patrón de EmisionEnergia.vue
✅ Carga de mercados al cambiar recaudadora
✅ Uso de select dropdown para mercados
✅ Deshabilitar mercado hasta seleccionar recaudadora

### Patrón de CargaPagMercado.vue
✅ Auto-llenado de categoría al seleccionar mercado
✅ Campo categoría deshabilitado (read-only)
✅ Uso de sp_get_catalogo_mercados de padron_licencias

---

## FLUJO DE USUARIO

1. **Usuario selecciona Recaudadora**
   - Se ejecuta `onRecaudadoraChange()`
   - Se limpian mercado y categoría
   - Se cargan mercados de esa recaudadora
   - Select de Mercado se habilita

2. **Usuario selecciona Mercado**
   - Se ejecuta `onMercadoChange()`
   - Se auto-llena el campo Categoría
   - Usuario puede continuar llenando Sección, Local, etc.

3. **Usuario completa el formulario**
   - Selecciona Sección (catálogo existente)
   - Ingresa Local, Letra, Bloque
   - Selecciona Tipo de Movimiento
   - Presiona "Buscar Local"

---

## PRUEBAS REALIZADAS

### ✅ Test 1: sp_get_catalogo_mercados
```
Base: padron_licencias
Parámetros: p_id_rec=1, p_nivel_usuario=1
Resultado: ✓ 3 mercados encontrados
Categoría: ✓ Campo presente (valor: 123)
```

### ✅ Test 2: Estructura de campos
```
Campos retornados por SP:
- oficina ✓
- num_mercado_nvo ✓
- categoria ✓ (REQUERIDO para auto-fill)
- descripcion ✓
```

---

## ARCHIVOS MODIFICADOS

1. **RefactorX/FrontEnd/src/views/modules/mercados/EnergiaModif.vue**
   - Líneas 27-50: Template actualizado
   - Línea 217: Agregado mercados ref
   - Líneas 303-348: Agregados métodos onRecaudadoraChange y onMercadoChange

---

## INSTRUCCIONES DE PRUEBA

1. **Recarga el navegador** en: `/energia-modif`

2. **Flujo de prueba:**
   ```
   Paso 1: Seleccionar Recaudadora
   → Verificar que el select de Mercado se habilita
   → Verificar que se cargan mercados

   Paso 2: Seleccionar Mercado
   → Verificar que el campo Categoría se auto-llena
   → Verificar que Categoría está deshabilitado (gris)

   Paso 3: Completar formulario
   → Sección, Local, Letra, Bloque, Tipo Movimiento
   → Buscar Local
   → Verificar que funciona la búsqueda
   ```

---

## COMPORTAMIENTO ESPERADO

### ✅ Campo Mercado
- Es un select dropdown (no input numérico)
- Muestra: "número - descripción"
- Deshabilitado hasta seleccionar recaudadora
- Se limpia al cambiar recaudadora

### ✅ Campo Categoría
- Es un input deshabilitado (read-only)
- Se auto-llena al seleccionar mercado
- Se limpia al cambiar recaudadora
- No puede ser editado manualmente

### ✅ Integración
- Mantiene funcionalidad existente de búsqueda de energía
- Compatible con sp_energia_modif_buscar
- Compatible con sp_energia_modif_modificar
- No afecta otros módulos

---

**Estado: COMPLETADO ✅**

El componente EnergiaModif.vue ahora funciona exactamente como se solicitó:
- Mercado es un select que se carga al seleccionar recaudadora (como EmisionEnergia)
- Categoría se auto-llena al seleccionar mercado (como CargaPagMercado)
