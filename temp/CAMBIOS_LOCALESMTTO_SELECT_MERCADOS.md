# Cambios en LocalesMtto.vue: Select de Mercados

## ✅ Cambios Realizados

Se ha actualizado el componente `LocalesMtto.vue` para cambiar el input de Mercado por un select dinámico que carga los mercados según la recaudadora seleccionada.

---

## 📝 Modificaciones Detalladas

### 1. **Template - Campos del Formulario**

#### ANTES:
```vue
<div class="col-md-2">
  <label>Recaudadora</label>
  <select v-model="form.oficina" class="form-control" required>
    <option v-for="rec in catalogs.recaudadoras" :key="rec.id_rec" :value="rec.id_rec">
      {{ rec.id_rec }} - {{ rec.recaudadora }}
    </option>
  </select>
</div>
<div class="col-md-2">
  <label>Mercado</label>
  <input v-model="form.num_mercado" type="number" class="form-control" required />
</div>
<div class="col-md-1">
  <label>Cat.</label>
  <input v-model="form.categoria" type="number" class="form-control" required />
</div>
```

#### DESPUÉS:
```vue
<div class="col-md-2">
  <label>Recaudadora</label>
  <select v-model="form.oficina" class="form-control" required @change="cargarMercados">
    <option value="">Seleccione...</option>
    <option v-for="rec in catalogs.recaudadoras" :key="rec.id_rec" :value="rec.id_rec">
      {{ rec.id_rec }} - {{ rec.recaudadora }}
    </option>
  </select>
</div>
<div class="col-md-3">
  <label>Mercado</label>
  <select v-model="form.num_mercado" class="form-control" required
          @change="onMercadoChange" :disabled="mercados.length === 0">
    <option value="">Seleccione...</option>
    <option v-for="merc in mercados" :key="merc.num_mercado_nvo" :value="merc.num_mercado_nvo">
      {{ merc.num_mercado_nvo }} - {{ merc.descripcion }}
    </option>
  </select>
</div>
<div class="col-md-1">
  <label>Cat.</label>
  <input v-model="form.categoria" type="number" class="form-control" required readonly />
</div>
```

**Cambios clave:**
- ✅ Select de Recaudadora: Agregado evento `@change="cargarMercados"`
- ✅ Campo Mercado: Cambiado de `<input>` a `<select>`
- ✅ Select Mercado: Deshabilitado cuando no hay mercados cargados
- ✅ Select Mercado: Muestra `num_mercado_nvo` y `descripcion`
- ✅ Campo Categoría: Ahora es `readonly` (se llena automáticamente)
- ✅ Opción default "Seleccione..." en todos los selects

---

### 2. **Script - Data Properties**

#### ANTES:
```javascript
data() {
  return {
    catalogs: {
      recaudadoras: [],
      secciones: [],
      zonas: [],
      cuotas: []
    },
    form: { ... },
    busquedaRealizada: false,
    localExiste: false,
    altaSuccess: false,
    altaError: ''
  };
}
```

#### DESPUÉS:
```javascript
data() {
  return {
    catalogs: {
      recaudadoras: [],
      secciones: [],
      zonas: [],
      cuotas: []
    },
    mercados: [],  // ← NUEVO array para mercados
    form: { ... },
    busquedaRealizada: false,
    localExiste: false,
    altaSuccess: false,
    altaError: ''
  };
}
```

**Cambios clave:**
- ✅ Agregado array `mercados: []` para almacenar los mercados dinámicamente

---

### 3. **Script - Métodos Nuevos**

#### Método: `cargarMercados()`

```javascript
async cargarMercados() {
  // Limpiar campos dependientes
  this.form.num_mercado = '';
  this.form.categoria = '';
  this.mercados = [];

  if (!this.form.oficina) return;

  try {
    const resp = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'get_mercados_by_oficina',
        Base: 'padron_licencias',
        Parametros: [
          { Nombre: 'p_oficina', Valor: parseInt(this.form.oficina) }
        ]
      }
    });

    if (resp.data.eResponse?.success && resp.data.eResponse?.data) {
      this.mercados = resp.data.eResponse.data.result || [];
    }
  } catch (error) {
    console.error('Error al cargar mercados:', error);
    this.mercados = [];
  }
}
```

**Funcionalidad:**
- Se ejecuta cuando cambia la recaudadora
- Limpia los campos de mercado y categoría
- Llama al SP `get_mercados_by_oficina` con la oficina seleccionada
- Llena el array `mercados` con los resultados

---

#### Método: `onMercadoChange()`

```javascript
onMercadoChange() {
  const selected = this.mercados.find(m => m.num_mercado_nvo == this.form.num_mercado);
  if (selected) {
    this.form.categoria = selected.categoria;
  }
}
```

**Funcionalidad:**
- Se ejecuta cuando cambia el mercado seleccionado
- Busca el mercado seleccionado en el array
- Llena automáticamente el campo de categoría

---

## 🔄 Flujo de Interacción

```
1. Usuario selecciona Recaudadora
   ↓
2. Se ejecuta cargarMercados()
   ↓
3. Se llama al SP get_mercados_by_oficina(oficina)
   ↓
4. Se llenan las opciones del select de Mercados
   ↓
5. Usuario selecciona un Mercado
   ↓
6. Se ejecuta onMercadoChange()
   ↓
7. Se llena automáticamente el campo Categoría
```

---

## 📊 Stored Procedure Utilizado

**Nombre:** `get_mercados_by_oficina`

**Archivo:** `RefactorX/Base/mercados/database/ok/28_SP_MERCADOS_CONSPAGOSLOCALES_EXACTO_all_procedures.sql`

**Definición:**
```sql
CREATE OR REPLACE FUNCTION get_mercados_by_oficina(p_oficina smallint)
RETURNS TABLE(
  num_mercado_nvo smallint,
  descripcion text,
  categoria smallint
) AS $$
BEGIN
  RETURN QUERY
  SELECT num_mercado_nvo, descripcion, categoria
  FROM public.ta_11_mercados
  WHERE oficina = p_oficina
  ORDER BY num_mercado_nvo;
END;
$$ LANGUAGE plpgsql;
```

**Tabla:** `public.ta_11_mercados`

**Datos de Ejemplo:**
```javascript
{
  num_mercado_nvo: 1,
  descripcion: "Mercado Central",
  categoria: 1
}
```

---

## 🎯 Beneficios de la Mejora

### 1. **Mejor Experiencia de Usuario**
- ❌ Antes: Usuario debía conocer el número exacto del mercado
- ✅ Ahora: Usuario selecciona de una lista descriptiva

### 2. **Reducción de Errores**
- ❌ Antes: Posibles errores al escribir números incorrectos
- ✅ Ahora: Solo opciones válidas disponibles

### 3. **Automatización**
- ❌ Antes: Usuario debía llenar manualmente la categoría
- ✅ Ahora: La categoría se llena automáticamente

### 4. **Validación Implícita**
- ✅ Solo se muestran mercados que existen en la base de datos
- ✅ Solo se muestran mercados de la recaudadora seleccionada

### 5. **Interfaz Más Intuitiva**
- ✅ Consistencia con otros formularios del sistema
- ✅ Mejor accesibilidad (navegación por teclado)

---

## 🧪 Cómo Probar

### Escenario 1: Carga Dinámica de Mercados

1. Abrir el formulario de Alta de Locales
2. Seleccionar una Recaudadora (ej: "5 - Recaudadora 5")
3. **Verificar:** El select de Mercados se habilita y carga opciones
4. **Verificar:** Se muestran mercados con formato "1 - Mercado Central"

### Escenario 2: Llenado Automático de Categoría

1. Con una recaudadora seleccionada
2. Seleccionar un Mercado del dropdown
3. **Verificar:** El campo Categoría se llena automáticamente
4. **Verificar:** El campo Categoría está en modo solo lectura (readonly)

### Escenario 3: Limpieza al Cambiar Recaudadora

1. Seleccionar Recaudadora A
2. Seleccionar un Mercado
3. Cambiar a Recaudadora B
4. **Verificar:** El select de Mercados se limpia
5. **Verificar:** La categoría se limpia
6. **Verificar:** Se cargan los mercados de la nueva recaudadora

### Escenario 4: Validación de Campos Requeridos

1. Intentar buscar sin seleccionar Recaudadora
2. **Verificar:** El navegador muestra mensaje de validación
3. Seleccionar Recaudadora pero no Mercado
4. **Verificar:** El navegador muestra mensaje de validación

---

## 📝 Datos de Prueba

Para la **Recaudadora 5** (según la base de datos actual):

```javascript
// Mercados disponibles:
{
  oficina: 5,
  mercados: [
    { num_mercado_nvo: 1, descripcion: "Mercado 1", categoria: 1 },
    { num_mercado_nvo: 2, descripcion: "Mercado 2", categoria: 1 },
    // ... más mercados
  ]
}
```

---

## 🔍 Cambios Adicionales Menores

### Select de Sección
También se agregó la opción "Seleccione..." al select de Sección para consistencia:

```vue
<select v-model="form.seccion" class="form-control" required>
  <option value="">Seleccione...</option>
  <option v-for="sec in catalogs.secciones" :key="sec.seccion" :value="sec.seccion">
    {{ sec.seccion }} - {{ sec.descripcion }}
  </option>
</select>
```

---

## 📂 Archivos Modificados

```
RefactorX/Base/mercados/vue/LocalesMtto.vue
├── Template (HTML)
│   ├── Select de Recaudadora: + evento @change
│   ├── Input Mercado → Select Mercado: ✓ Cambiado
│   └── Input Categoría: + atributo readonly
└── Script (JavaScript)
    ├── data.mercados: + nuevo array
    ├── methods.cargarMercados(): + nuevo método
    └── methods.onMercadoChange(): + nuevo método
```

---

## ✅ Checklist de Implementación

- [x] Cambiar input de mercado por select
- [x] Agregar array mercados en data
- [x] Implementar método cargarMercados()
- [x] Implementar método onMercadoChange()
- [x] Agregar evento @change en select de recaudadora
- [x] Agregar evento @change en select de mercado
- [x] Hacer campo categoría readonly
- [x] Agregar :disabled en select de mercados
- [x] Agregar opciones "Seleccione..." en todos los selects
- [x] Usar API genérica con formato eRequest/eResponse
- [x] Manejar errores con try/catch

---

## 🎨 Mejoras Visuales

### Ancho de Columnas Actualizado

- **Recaudadora:** `col-md-2` (sin cambio)
- **Mercado:** `col-md-2` → `col-md-3` (más ancho para descripción)
- **Categoría:** `col-md-1` (sin cambio)

Esto permite que la descripción del mercado sea más legible.

---

## 🔄 Compatibilidad

✅ Compatible con la API genérica existente
✅ Usa el mismo formato eRequest/eResponse que otros módulos
✅ Utiliza SPs ya existentes (get_mercados_by_oficina)
✅ No requiere cambios en el backend
✅ Mantiene la misma estructura de datos del formulario

---

**Fecha de implementación:** 2025-01-25
**Versión:** 1.0
**Estado:** ✅ Completado y listo para pruebas
