# LoadingOverlay - Componente de Carga Global

## 📋 Descripción
Componente reutilizable para mostrar un indicador de carga (loading) con el logo institucional y mensaje personalizable. Se puede usar en cualquier parte del sistema.

## 🎯 Uso

### 1. Importar el componente
```javascript
import LoadingOverlay from '@/components/common/LoadingOverlay.vue'
```

### 2. Agregar al template
```vue
<template>
  <div>
    <!-- Tu contenido aquí -->

    <LoadingOverlay
      :show="loading"
      message="Cargando datos..."
      subMessage="Por favor espere"
    />
  </div>
</template>
```

### 3. Controlar la visibilidad
```javascript
const loading = ref(false)

// Mostrar loading
loading.value = true

// Ocultar loading
loading.value = false
```

## ⚙️ Props

| Prop | Tipo | Default | Descripción |
|------|------|---------|-------------|
| `show` | Boolean | `false` | Controla la visibilidad del loading |
| `message` | String | `'Cargando...'` | Mensaje principal que se muestra |
| `subMessage` | String | `''` | Mensaje secundario opcional |
| `fullscreen` | Boolean | `false` | Si es `true`, cubre toda la pantalla; si es `false`, solo cubre el contenedor padre |

## 📝 Ejemplos

### Ejemplo 1: Loading en Modal
```vue
<Modal :show="showModal">
  <LoadingOverlay
    :show="loadingModal"
    message="Guardando cambios..."
    subMessage="Por favor espere"
  />

  <!-- Contenido del modal -->
</Modal>
```

### Ejemplo 2: Loading Fullscreen
```vue
<LoadingOverlay
  :show="loading"
  message="Procesando información..."
  subMessage="Esto puede tardar unos segundos"
  fullscreen
/>
```

### Ejemplo 3: Loading Simple
```vue
<div class="card">
  <LoadingOverlay :show="loading" />

  <!-- Contenido de la tarjeta -->
</div>
```

### Ejemplo 4: Loading con Async/Await
```javascript
const guardarDatos = async () => {
  loadingModal.value = true

  try {
    await api.guardar(datos)
    showToast('success', 'Datos guardados correctamente')
  } catch (error) {
    showToast('error', 'Error al guardar')
  } finally {
    loadingModal.value = false
  }
}
```

## 🎨 Estilos

El componente incluye:
- ✅ Logo animado giratorio
- ✅ Texto con animación de pulso
- ✅ Backdrop con blur
- ✅ Transición suave de entrada/salida
- ✅ Diseño responsive
- ✅ Z-index alto (9999) para estar siempre visible

## 🔧 Posicionamiento

### Contenedor relativo (default)
```css
/* El contenedor padre debe tener position: relative */
.mi-contenedor {
  position: relative;
}
```

### Fullscreen
```vue
<LoadingOverlay :show="loading" fullscreen />
<!-- Cubre toda la pantalla, no necesita contenedor padre -->
```

## 📦 Casos de Uso

1. **Formularios**: Mostrar loading al guardar/actualizar datos
2. **Búsquedas**: Indicar que se están buscando resultados
3. **Cargas de datos**: Al cargar información del backend
4. **Operaciones largas**: Procesos que toman varios segundos
5. **Modales**: Loading dentro de diálogos y modales

## ⚠️ Notas Importantes

- El loading usa `position: absolute` por defecto, requiere que el contenedor padre tenga `position: relative`
- Con `fullscreen="true"`, usa `position: fixed` y cubre toda la ventana
- El logo debe estar en `/public/logo1.png` o actualizar la ruta en el componente
- Los estilos son globales (sin scoped) para poder usarse en cualquier componente

## 🚀 Integración en Componentes Existentes

### Paso 1: Importar
```javascript
import LoadingOverlay from '@/components/common/LoadingOverlay.vue'
```

### Paso 2: Agregar variable de estado
```javascript
const loading = ref(false)
```

### Paso 3: Agregar al template
```vue
<LoadingOverlay :show="loading" message="Tu mensaje aquí" />
```

### Paso 4: Usar en funciones
```javascript
const miFuncion = async () => {
  loading.value = true
  try {
    await hacerAlgo()
  } finally {
    loading.value = false
  }
}
```

## 🎯 Ejemplo Completo

```vue
<template>
  <div class="mi-modulo">
    <button @click="cargarDatos">Cargar Datos</button>

    <div class="resultados" style="position: relative;">
      <LoadingOverlay
        :show="loading"
        message="Cargando resultados..."
        subMessage="Consultando base de datos"
      />

      <div v-if="!loading">
        <!-- Mostrar resultados aquí -->
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import LoadingOverlay from '@/components/common/LoadingOverlay.vue'

const loading = ref(false)
const resultados = ref([])

const cargarDatos = async () => {
  loading.value = true

  try {
    const response = await fetch('/api/datos')
    resultados.value = await response.json()
  } catch (error) {
    console.error('Error:', error)
  } finally {
    loading.value = false
  }
}
</script>
```

## 📱 Responsive

El componente es totalmente responsive y se adapta a:
- Desktop (1920px+)
- Laptop (1024px-1920px)
- Tablet (768px-1024px)
- Mobile (320px-768px)

## 🎨 Personalización

Si necesitas personalizar los estilos, puedes sobrescribir las clases CSS:

```css
/* En tu componente o en estilos globales */
.loading-logo-spin {
  width: 100px !important;  /* Tamaño del logo */
}

.loading-text-global {
  color: #9264cc !important;  /* Color del texto */
}
```

## ✅ Checklist de Implementación

- [ ] Importar el componente
- [ ] Crear variable `loading` con ref(false)
- [ ] Agregar `<LoadingOverlay>` al template
- [ ] Configurar `position: relative` en contenedor padre (si no es fullscreen)
- [ ] Activar loading antes de operación async
- [ ] Desactivar loading en finally
- [ ] Probar en diferentes dispositivos

---

**Creado por**: Sistema RefactorX
**Fecha**: 2025-11-04
**Versión**: 1.0.0
