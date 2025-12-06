# VERIFICACIÓN: LocalesModif.vue
**Fecha:** 2025-12-05
**Módulo:** /locales-modif (Modificación de Locales)
**Estado:** ✅ YA IMPLEMENTADO CORRECTAMENTE

---

## SOLICITUD DEL USUARIO

> "aplica el ajuste de cargar un mercado por recaudadora en locales-modif, igual auto asignar cat."

---

## ESTADO ACTUAL: ✅ YA IMPLEMENTADO

El componente **LocalesModif.vue** YA TIENE todas las funcionalidades solicitadas correctamente implementadas:

---

## 1. CAMPO MERCADO COMO SELECT ✅

**Ubicación:** Líneas 32-39

```vue
<div class="form-group" style="flex: 2;">
  <label class="municipal-form-label">Mercado <span class="required">*</span></label>
  <select v-model.number="form.num_mercado" class="municipal-form-control" required
    :disabled="!form.oficina || loading" @change="onMercadoChange">
    <option value="">Seleccione...</option>
    <option v-for="m in catalogos.mercados" :key="m.num_mercado_nvo" :value="m.num_mercado_nvo">
      {{ m.num_mercado_nvo }} - {{ m.descripcion }}
    </option>
  </select>
</div>
```

**Características:**
- ✅ Es un select dropdown (no input numérico)
- ✅ Muestra "número - descripción"
- ✅ Deshabilitado hasta que se seleccione recaudadora
- ✅ Tiene @change="onMercadoChange" para auto-llenar categoría

---

## 2. CARGA DE MERCADOS AL CAMBIAR RECAUDADORA ✅

**Ubicación:** Líneas 23-24, 388-417

### En el Template:
```vue
<select v-model="form.oficina" class="municipal-form-control" required
  :disabled="loading" @change="onRecChange">
```

### En el Script:
```javascript
const onRecChange = async () => {
  // Limpiar mercado y categoría al cambiar recaudadora
  form.value.num_mercado = ''
  form.value.categoria = ''
  catalogos.value.mercados = []

  if (!form.value.oficina) return

  // Cargar mercados
  try {
    const nivelUsuario = 1
    const res = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_get_catalogo_mercados',
        Base: 'padron_licencias',
        Parametros: [
          { Nombre: 'p_oficina', Valor: parseInt(form.value.oficina) },
          { Nombre: 'p_nivel_usuario', Valor: nivelUsuario }
        ]
      }
    })

    if (res.data?.eResponse?.success) {
      catalogos.value.mercados = res.data.eResponse.data.result || []
    }
  } catch (error) {
    console.error('Error al cargar mercados:', error)
    toast.error('Error al cargar mercados')
  }
}
```

**Características:**
- ✅ Limpia el mercado y categoría seleccionados
- ✅ Carga mercados usando `sp_get_catalogo_mercados`
- ✅ Base de datos: `padron_licencias`
- ✅ Maneja errores con toast
- ✅ Retorna mercados con categoría incluida

---

## 3. AUTO-LLENADO DE CATEGORÍA ✅

**Ubicación:** Líneas 419-428

```javascript
const onMercadoChange = () => {
  // Auto-asignar categoría basada en el mercado seleccionado
  const selected = catalogos.value.mercados.find(m => m.num_mercado_nvo == form.value.num_mercado)

  if (selected && selected.categoria) {
    form.value.categoria = selected.categoria
  } else {
    form.value.categoria = ''
  }
}
```

**Características:**
- ✅ Busca el mercado seleccionado en el array
- ✅ Auto-llena el campo categoría con el valor del mercado
- ✅ Limpia categoría si no se encuentra el mercado

---

## 4. CAMPO CATEGORÍA DESHABILITADO ✅

**Ubicación:** Líneas 42-49

```vue
<div class="form-group">
  <label class="municipal-form-label">Cat. <span class="required">*</span></label>
  <select v-model.number="form.categoria" class="municipal-form-control" disabled
    style="background-color: #f0f0f0; cursor: not-allowed;">
    <option value="">-</option>
    <option v-for="c in catalogos.categorias" :key="c.categoria" :value="c.categoria">
      {{ c.categoria }} - {{ c.descripcion }}
    </option>
  </select>
</div>
```

**Características:**
- ✅ Campo deshabilitado (disabled)
- ✅ Estilo visual de campo read-only (fondo gris, cursor no permitido)
- ✅ No puede ser editado manualmente

---

## FLUJO COMPLETO IMPLEMENTADO

### 1. Usuario selecciona Recaudadora
```
→ Se ejecuta onRecChange()
→ Se limpian mercado y categoría
→ Se cargan mercados de esa recaudadora
→ Select de Mercado se habilita
```

### 2. Usuario selecciona Mercado
```
→ Se ejecuta onMercadoChange()
→ Se auto-llena el campo Categoría
→ Usuario puede continuar llenando los demás campos
```

### 3. Usuario completa el formulario
```
→ Sección, Local, Letra, Bloque
→ Presiona "Buscar"
→ Se carga el local existente para modificar
```

---

## STORED PROCEDURE UTILIZADO

### sp_get_catalogo_mercados
- **Base de datos:** padron_licencias
- **Parámetros:**
  - p_oficina (INTEGER) - ID de la recaudadora
  - p_nivel_usuario (INTEGER) - Nivel de acceso (siempre 1)

**Campos retornados:**
- oficina (SMALLINT)
- num_mercado_nvo (SMALLINT)
- **categoria (SMALLINT)** ⭐ REQUERIDO para auto-fill
- descripcion (VARCHAR)
- cuenta_ingreso (INTEGER)
- cuenta_energia (INTEGER)
- id_zona (SMALLINT)
- zona (VARCHAR)
- tipo_emision (VARCHAR)

✅ **VERIFICADO:** El SP retorna la categoría correctamente

---

## COMPARACIÓN CON EnergiaModif.vue

| Característica | EnergiaModif.vue | LocalesModif.vue | Estado |
|----------------|------------------|------------------|--------|
| Mercado como Select | ✅ Implementado | ✅ Implementado | ✅ Igual |
| Carga por Recaudadora | ✅ onRecaudadoraChange | ✅ onRecChange | ✅ Igual |
| Auto-fill Categoría | ✅ onMercadoChange | ✅ onMercadoChange | ✅ Igual |
| Categoría Disabled | ✅ disabled | ✅ disabled | ✅ Igual |
| SP Utilizado | sp_get_catalogo_mercados | sp_get_catalogo_mercados | ✅ Igual |
| Base de Datos | padron_licencias | padron_licencias | ✅ Igual |

---

## CONCLUSIÓN

✅ **NO SE REQUIEREN CAMBIOS**

El componente LocalesModif.vue **ya tiene implementadas todas las funcionalidades solicitadas**:

1. ✅ Campo Mercado es un select dropdown
2. ✅ Carga mercados al seleccionar recaudadora
3. ✅ Auto-llena categoría al seleccionar mercado
4. ✅ Categoría está deshabilitada (read-only)

---

## INSTRUCCIONES DE PRUEBA

Para verificar que todo funciona correctamente:

1. **Abre el navegador** en: `/locales-modif`

2. **Prueba el flujo:**
   ```
   Paso 1: Seleccionar Recaudadora
   → Verificar que el select de Mercado se habilita
   → Verificar que se cargan mercados

   Paso 2: Seleccionar Mercado
   → Verificar que el campo Categoría se auto-llena
   → Verificar que Categoría está deshabilitado (gris)

   Paso 3: Completar formulario de búsqueda
   → Sección, Local, Letra, Bloque
   → Buscar Local
   → Verificar que carga el local para modificar
   ```

---

**Estado: YA IMPLEMENTADO ✅**

El componente LocalesModif.vue funciona exactamente como EnergiaModif.vue y como se solicitó. No se requieren cambios adicionales.
