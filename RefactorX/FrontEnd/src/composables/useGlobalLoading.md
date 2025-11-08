# useGlobalLoading - Sistema de Loading Global

## 📋 Descripción
Composable para controlar el loading fullscreen global del sistema. Una vez configurado en `App.vue`, se puede usar desde cualquier componente para mostrar un indicador de carga que cubre toda la pantalla.

## ✅ Configuración Inicial (Ya realizada)

El loading global ya está configurado en `App.vue`:

```vue
<template>
  <MainLayout />
  <GlobalLoading />  <!-- ✅ Ya configurado -->
</template>

<script setup>
import GlobalLoading from './components/common/GlobalLoading.vue'
</script>
```

## 🎯 Uso en Componentes

### 1. Importar el composable

```javascript
import { useGlobalLoading } from '@/composables/useGlobalLoading'

const { showLoading, hideLoading } = useGlobalLoading()
```

### 2. Mostrar y ocultar loading

```javascript
// Mostrar loading
showLoading('Cargando datos...', 'Por favor espere')

// Ocultar loading
hideLoading()
```

## 📝 Métodos Disponibles

### `showLoading(message, subMessage)`
Muestra el loading fullscreen global.

**Parámetros:**
- `message` (String, opcional): Mensaje principal. Default: 'Cargando...'
- `subMessage` (String, opcional): Mensaje secundario. Default: ''

```javascript
// Solo mensaje principal
showLoading('Guardando cambios...')

// Mensaje principal y secundario
showLoading('Procesando información...', 'Esto puede tardar unos segundos')
```

### `hideLoading()`
Oculta el loading global.

```javascript
hideLoading()
```

### `withLoading(asyncFn, message, subMessage)`
Ejecuta una función async con loading automático.

**Parámetros:**
- `asyncFn` (Function): Función async a ejecutar
- `message` (String, opcional): Mensaje del loading
- `subMessage` (String, opcional): Submensaje del loading

**Retorna:** Promise con el resultado de la función

```javascript
const resultado = await withLoading(
  async () => {
    return await api.getData()
  },
  'Cargando datos...',
  'Consultando base de datos'
)
```

## 📦 Ejemplos Prácticos

### Ejemplo 1: Operación async básica

```javascript
import { useGlobalLoading } from '@/composables/useGlobalLoading'

const { showLoading, hideLoading } = useGlobalLoading()

const guardarDatos = async () => {
  showLoading('Guardando datos...', 'Por favor espere')

  try {
    await api.guardar(datos)
    console.log('Datos guardados')
  } catch (error) {
    console.error('Error:', error)
  } finally {
    hideLoading()
  }
}
```

### Ejemplo 2: Con try-catch-finally

```javascript
const cargarUsuarios = async () => {
  showLoading('Cargando usuarios...', 'Consultando base de datos')

  try {
    const response = await execute('get_usuarios', ...)
    usuarios.value = response.result
    showToast('success', 'Usuarios cargados')
  } catch (error) {
    handleApiError(error)
  } finally {
    hideLoading() // Siempre se ejecuta
  }
}
```

### Ejemplo 3: Usando withLoading (forma corta)

```javascript
const { withLoading } = useGlobalLoading()

const buscarDatos = async () => {
  const resultados = await withLoading(
    async () => await api.buscar(query),
    'Buscando...',
    'Por favor espere'
  )

  console.log('Resultados:', resultados)
}
```

### Ejemplo 4: Múltiples operaciones

```javascript
const procesarTodo = async () => {
  // Paso 1: Cargar datos
  showLoading('Paso 1/3: Cargando datos...', 'Consultando servidor')
  await cargarDatos()

  // Paso 2: Validar
  showLoading('Paso 2/3: Validando...', 'Verificando información')
  await validar()

  // Paso 3: Guardar
  showLoading('Paso 3/3: Guardando...', 'Finalizando proceso')
  await guardar()

  hideLoading()
}
```

### Ejemplo 5: Con modal de edición

```javascript
const abrirModalEditar = async (usuario) => {
  showLoading('Preparando edición...', 'Cargando información del usuario')

  // Cargar datos relacionados
  await cargarDepartamentos(usuario.idDependencia)

  // Preparar formulario
  formEditar.value = { ...usuario }

  // Pequeño delay para UX
  await new Promise(resolve => setTimeout(resolve, 200))

  // Mostrar modal y ocultar loading
  showModalEditar.value = true
  hideLoading()
}
```

## 🎨 Casos de Uso Comunes

| Caso de Uso | Mensaje | Submensaje |
|-------------|---------|------------|
| Carga inicial | "Cargando..." | "Por favor espere" |
| Búsqueda | "Buscando..." | "Consultando base de datos" |
| Guardando | "Guardando cambios..." | "Por favor espere" |
| Actualizando | "Actualizando..." | "Procesando información" |
| Eliminando | "Eliminando..." | "Por favor espere" |
| Carga de datos | "Cargando datos..." | "Consultando servidor" |
| Preparando edición | "Preparando edición..." | "Cargando información" |
| Procesando | "Procesando..." | "Esto puede tardar unos segundos" |

## ⚠️ Mejores Prácticas

### ✅ Hacer

```javascript
// Usar try-finally para asegurar que siempre se oculte
const guardar = async () => {
  showLoading('Guardando...')
  try {
    await api.guardar()
  } finally {
    hideLoading() // ✅ Siempre se ejecuta
  }
}

// Mensajes descriptivos
showLoading('Procesando pago...', 'Conectando con banco')

// Ocultar antes de mostrar modal
hideLoading()
showModal()
```

### ❌ Evitar

```javascript
// No olvidar hideLoading()
const guardar = async () => {
  showLoading('Guardando...')
  await api.guardar()
  // ❌ Falta hideLoading()
}

// No usar mensajes genéricos
showLoading('Cargando...') // ❌ Poco descriptivo

// No dejar loading activo al navegar
router.push('/otra-pagina') // ❌ Antes debes hacer hideLoading()
```

## 🔧 Integración Completa en Componente

```vue
<template>
  <div>
    <button @click="cargarDatos">Cargar Datos</button>
    <button @click="guardarDatos">Guardar</button>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import { useApi } from '@/composables/useApi'

const { showLoading, hideLoading } = useGlobalLoading()
const { execute } = useApi()

const datos = ref([])

const cargarDatos = async () => {
  showLoading('Cargando datos...', 'Consultando base de datos')

  try {
    const response = await execute('get_datos', ...)
    datos.value = response.result
  } catch (error) {
    console.error('Error:', error)
  } finally {
    hideLoading()
  }
}

const guardarDatos = async () => {
  showLoading('Guardando cambios...', 'Por favor espere')

  try {
    await execute('guardar_datos', ...)
    alert('Datos guardados correctamente')
  } catch (error) {
    alert('Error al guardar')
  } finally {
    hideLoading()
  }
}
</script>
```

## 🎯 Estado Global Compartido

El estado del loading es **global y compartido** entre todos los componentes:

```javascript
// Componente A
showLoading('Cargando...') // ✅ Se ve en todo el sitio

// Componente B
hideLoading() // ✅ Se oculta desde cualquier componente
```

## 📱 Características del Loading

- ✅ **Fullscreen**: Cubre toda la pantalla (z-index: 99999)
- ✅ **Backdrop oscuro**: rgba(0, 0, 0, 0.5)
- ✅ **Logo animado**: Animación pulse suave
- ✅ **Mensajes personalizables**: Mensaje principal y secundario
- ✅ **Transiciones suaves**: Fade in/out
- ✅ **Bloqueante**: No permite interacción mientras está activo

## 🚀 Ventajas del Sistema Global

1. **Un solo loading para todo**: No múltiples overlays locales
2. **Consistencia visual**: Mismo diseño en todo el sitio
3. **Fácil de usar**: Solo 2 funciones: showLoading() y hideLoading()
4. **Mantenible**: Cambios en un solo lugar
5. **Sin prop drilling**: No necesitas pasar props
6. **Estado compartido**: Funciona desde cualquier componente

## ✅ Checklist de Uso

- [ ] Importar `useGlobalLoading`
- [ ] Desestructurar `showLoading` y `hideLoading`
- [ ] Llamar `showLoading()` antes de operación async
- [ ] Usar `try-finally` para asegurar `hideLoading()`
- [ ] Mensajes descriptivos y claros
- [ ] Probar en diferentes escenarios

---

**Creado por**: Sistema RefactorX
**Fecha**: 2025-11-04
**Versión**: 1.0.0
