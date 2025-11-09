<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header" >
      <div class="module-view-icon">
        <font-awesome-icon icon="signature" />
      </div>
      <div class="module-view-info">
        <h1>Firma Digital</h1>
        <p>Padrón de Licencias - Captura de Firma Digital para Trámites</p></div>
      <button
        type="button"
        class="btn-help-icon"
        @click="openDocumentation"
        title="Ayuda"
      >
        <font-awesome-icon icon="question-circle" />
      </button>
      <div class="module-view-actions">
        <button
          class="btn-municipal-secondary"
          @click="clearCanvas"
          :disabled="loading || !hasSignature"
        >
          <font-awesome-icon icon="eraser" />
          Limpiar
        </button>
        <button
          class="btn-municipal-primary"
          @click="saveSignature"
          :disabled="loading || !hasSignature"
        >
          <font-awesome-icon icon="save" />
          Guardar Firma
        </button>
      </div>
    </div>

    <div class="module-view-content">

    <!-- Instrucciones -->
    <div class="municipal-card">
      <div class="municipal-card-header">
        <h5>
          <font-awesome-icon icon="info-circle" />
          Instrucciones
        </h5>
      </div>
      <div class="municipal-card-body">
        <div class="instructions">
          <div class="instruction-item">
            <div class="instruction-icon">
              <font-awesome-icon icon="mouse-pointer" size="2x" />
            </div>
            <div class="instruction-text">
              <h6>1. Dibuje su firma</h6>
              <p>Use el mouse o su dedo (en pantalla táctil) para dibujar su firma en el recuadro</p>
            </div>
          </div>
          <div class="instruction-item">
            <div class="instruction-icon">
              <font-awesome-icon icon="eraser" size="2x" />
            </div>
            <div class="instruction-text">
              <h6>2. Limpiar si es necesario</h6>
              <p>Si no está conforme con su firma, puede limpiar el recuadro y volver a intentar</p>
            </div>
          </div>
          <div class="instruction-item">
            <div class="instruction-icon">
              <font-awesome-icon icon="save" size="2x" />
            </div>
            <div class="instruction-text">
              <h6>3. Guardar</h6>
              <p>Una vez satisfecho con su firma, haga clic en "Guardar Firma"</p>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Canvas de firma -->
    <div class="municipal-card">
      <div class="municipal-card-header">
        <h5>
          <font-awesome-icon icon="signature" />
          Área de Firma
        </h5>
      </div>
      <div class="municipal-card-body">
        <div class="signature-container">
          <canvas
            ref="signatureCanvas"
            class="signature-canvas"
            @mousedown="startDrawing"
            @mousemove="draw"
            @mouseup="stopDrawing"
            @mouseleave="stopDrawing"
            @touchstart="handleTouchStart"
            @touchmove="handleTouchMove"
            @touchend="stopDrawing"
          ></canvas>
          <div class="signature-placeholder" v-if="!isDrawing && !hasSignature">
            <font-awesome-icon icon="pen-fancy" size="3x" />
            <p>Dibuje su firma aquí</p>
          </div>
        </div>
        <div class="signature-tools">
          <div class="tool-group">
            <label class="municipal-form-label">Grosor de línea:</label>
            <input
              type="range"
              min="1"
              max="5"
              v-model="lineWidth"
              class="line-width-slider"
            >
            <span class="tool-value">{{ lineWidth }}px</span>
          </div>
          <div class="tool-group">
            <label class="municipal-form-label">Color:</label>
            <select v-model="lineColor" class="municipal-form-control color-select">
              <option value="#000000">Negro</option>
              <option value="#0000ff">Azul</option>
              <option value="#000080">Azul Oscuro</option>
            </select>
          </div>
        </div>
      </div>
    </div>

    <!-- Firma guardada -->
    <div class="municipal-card" v-if="savedSignature">
      <div class="municipal-card-header">
        <h5>
          <font-awesome-icon icon="check-circle" />
          Firma Guardada
        </h5>
      </div>
      <div class="municipal-card-body">
        <div class="saved-signature-container">
          <div class="saved-signature-info">
            <p>
              <font-awesome-icon icon="calendar" />
              <strong>Fecha de captura:</strong> {{ formatDateTime(savedSignature.fecha) }}
            </p>
            <p>
              <font-awesome-icon icon="user" />
              <strong>Usuario:</strong> {{ savedSignature.usuario }}
            </p>
            <p v-if="savedSignature.validada">
              <span class="badge badge-success">
                <font-awesome-icon icon="check-circle" />
                Firma Validada
              </span>
            </p>
            <p v-else>
              <span class="badge badge-warning">
                <font-awesome-icon icon="clock" />
                Pendiente de Validación
              </span>
            </p>
          </div>
          <div class="saved-signature-preview">
            <h6>Vista previa de la firma guardada:</h6>
            <img :src="savedSignature.imageData" alt="Firma guardada" class="signature-image">
          </div>
        </div>
        <div class="button-group mt-3">
          <button
            class="btn-municipal-primary"
            @click="validateSignature"
            :disabled="loading || savedSignature.validada"
          >
            <font-awesome-icon icon="check-double" />
            Validar Firma
          </button>
          <button
            class="btn-municipal-secondary"
            @click="confirmReSign"
            :disabled="loading"
          >
            <font-awesome-icon icon="redo" />
            Firmar Nuevamente
          </button>
        </div>
      </div>
    </div>

    <!-- Loading overlay -->
    <div v-if="loading" class="loading-overlay">
      <div class="loading-spinner">
        <div class="spinner"></div>
        <p>{{ loadingMessage }}</p>
      </div>
    </div>

    <!-- Toast Notifications -->
    </div>
    <!-- /module-view-content -->

    <!-- Toast Notifications -->
    <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
      <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
      <span class="toast-message">{{ toast.message }}</span>
      <button class="toast-close" @click="hideToast">
        <font-awesome-icon icon="times" />
      </button>
    </div>
  </div>
  <!-- /module-view -->

    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showDocumentation"
      :componentName="'firma'"
      :moduleName="'padron_licencias'"
      @close="closeDocumentation"
    />
  </template>

<script setup>
import DocumentationModal from '@/components/common/DocumentationModal.vue'

import { ref, onMounted, onBeforeUnmount, watch } from 'vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import Swal from 'sweetalert2'

// Composables
const showDocumentation = ref(false)
const openDocumentation = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false

const { execute } = useApi()
const {
  loading,
  setLoading,
  toast,
  showToast,
  hideToast,
  getToastIcon,
  handleApiError
} = useLicenciasErrorHandler()

// Referencias
const signatureCanvas = ref(null)
const canvasContext = ref(null)

// Estado
const isDrawing = ref(false)
const hasSignature = ref(false)
const lineWidth = ref(2)
const lineColor = ref('#000000')
const loadingMessage = ref('')
const savedSignature = ref(null)

// Posición del cursor/touch
const lastX = ref(0)
const lastY = ref(0)

// Métodos de dibujo
const initCanvas = () => {
  if (!signatureCanvas.value) return

  const canvas = signatureCanvas.value
  const container = canvas.parentElement

  // Configurar tamaño del canvas
  canvas.width = container.offsetWidth
  canvas.height = 300

  // Obtener contexto
  canvasContext.value = canvas.getContext('2d')

  // Configurar estilo
  canvasContext.value.lineCap = 'round'
  canvasContext.value.lineJoin = 'round'

  // Limpiar canvas
  canvasContext.value.fillStyle = '#ffffff'
  canvasContext.value.fillRect(0, 0, canvas.width, canvas.height)
}

const getCanvasCoordinates = (event) => {
  const canvas = signatureCanvas.value
  const rect = canvas.getBoundingClientRect()
  const scaleX = canvas.width / rect.width
  const scaleY = canvas.height / rect.height

  return {
    x: (event.clientX - rect.left) * scaleX,
    y: (event.clientY - rect.top) * scaleY
  }
}

const startDrawing = (event) => {
  event.preventDefault()
  isDrawing.value = true
  hasSignature.value = true

  const coords = getCanvasCoordinates(event)
  lastX.value = coords.x
  lastY.value = coords.y

  // Iniciar trazo
  canvasContext.value.beginPath()
  canvasContext.value.moveTo(coords.x, coords.y)
}

const draw = (event) => {
  if (!isDrawing.value) return
  event.preventDefault()

  const coords = getCanvasCoordinates(event)

  canvasContext.value.strokeStyle = lineColor.value
  canvasContext.value.lineWidth = lineWidth.value

  canvasContext.value.lineTo(coords.x, coords.y)
  canvasContext.value.stroke()

  lastX.value = coords.x
  lastY.value = coords.y
}

const stopDrawing = () => {
  if (isDrawing.value) {
    isDrawing.value = false
    canvasContext.value.closePath()
  }
}

// Soporte táctil
const handleTouchStart = (event) => {
  event.preventDefault()
  const touch = event.touches[0]
  const mouseEvent = new MouseEvent('mousedown', {
    clientX: touch.clientX,
    clientY: touch.clientY
  })
  startDrawing(mouseEvent)
}

const handleTouchMove = (event) => {
  event.preventDefault()
  const touch = event.touches[0]
  const mouseEvent = new MouseEvent('mousemove', {
    clientX: touch.clientX,
    clientY: touch.clientY
  })
  draw(mouseEvent)
}

const clearCanvas = () => {
  if (!canvasContext.value) return

  const canvas = signatureCanvas.value
  canvasContext.value.fillStyle = '#ffffff'
  canvasContext.value.fillRect(0, 0, canvas.width, canvas.height)

  hasSignature.value = false
  isDrawing.value = false
}

const saveSignature = async () => {
  if (!hasSignature.value) {
    showToast('warning', 'Primero debe dibujar su firma')
    return
  }

  const result = await Swal.fire({
    title: '¿Guardar firma?',
    text: '¿Está conforme con su firma y desea guardarla?',
    icon: 'question',
    showCancelButton: true,
    confirmButtonColor: '#ea8215',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, guardar',
    cancelButtonText: 'Cancelar'
  })

  if (!result.isConfirmed) return

  setLoading(true, 'Guardando firma...')
  loadingMessage.value = 'Guardando firma...'

  try {
    // Convertir canvas a base64
    const canvas = signatureCanvas.value
    const imageData = canvas.toDataURL('image/png')
    const base64 = imageData.split(',')[1]

    const usuario = localStorage.getItem('usuario') || 'sistema'
    const startTime = performance.now()

    const response = await execute(
      'sp_firma_save',
      'padron_licencias',
      [
        { nombre: 'p_signature_base64', valor: base64, tipo: 'string' },
        { nombre: 'p_usuario', valor: usuario, tipo: 'string' }
      ],
      'guadalajara'
    )
    const duration = ((performance.now() - startTime) / 1000).toFixed(2)

    if (response && response.result && response.result[0]?.success) {
      savedSignature.value = {
        id: response.result[0].id,
        fecha: new Date().toISOString(),
        usuario: 'usuario_actual',
        imageData: imageData,
        validada: false
      }

      await Swal.fire({
        icon: 'success',
        title: 'Firma guardada',
        text: 'Su firma ha sido guardada exitosamente',
        confirmButtonColor: '#ea8215',
        timer: 2000
      })

      showToast('success', `Firma guardada en ${duration}s`)
    } else {
      await Swal.fire({
        icon: 'error',
        title: 'Error al guardar',
        text: response?.result?.[0]?.message || 'Error desconocido',
        confirmButtonColor: '#ea8215'
      })
    }
  } catch (error) {
    handleApiError(error)
    await Swal.fire({
      icon: 'error',
      title: 'Error de conexión',
      text: 'No se pudo guardar la firma',
      confirmButtonColor: '#ea8215'
    })
  } finally {
    setLoading(false)
    loadingMessage.value = ''
  }
}

const validateSignature = async () => {
  const result = await Swal.fire({
    title: 'Validar firma',
    text: '¿Desea validar esta firma?',
    icon: 'question',
    showCancelButton: true,
    confirmButtonColor: '#28a745',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, validar',
    cancelButtonText: 'Cancelar'
  })

  if (!result.isConfirmed) return

  setLoading(true, 'Validando firma...')
  loadingMessage.value = 'Validando firma...'
  const startTime = performance.now()

  try {
    const response = await execute(
      'sp_firma_validate',
      'padron_licencias',
      [
        { nombre: 'p_signature_id', valor: savedSignature.value.id, tipo: 'integer' }
      ],
      'guadalajara'
    )
    const duration = ((performance.now() - startTime) / 1000).toFixed(2)

    if (response && response.result && response.result[0]?.success) {
      savedSignature.value.validada = true

      await Swal.fire({
        icon: 'success',
        title: 'Firma validada',
        text: 'La firma ha sido validada exitosamente',
        confirmButtonColor: '#ea8215',
        timer: 2000
      })

      showToast('success', `Firma validada en ${duration}s`)
    } else {
      await Swal.fire({
        icon: 'error',
        title: 'Error al validar',
        text: response?.result?.[0]?.message || 'Error desconocido',
        confirmButtonColor: '#ea8215'
      })
    }
  } catch (error) {
    handleApiError(error)
  } finally {
    setLoading(false)
    loadingMessage.value = ''
  }
}

const confirmReSign = async () => {
  const result = await Swal.fire({
    title: 'Firmar nuevamente',
    text: 'Esto eliminará la firma actual. ¿Desea continuar?',
    icon: 'warning',
    showCancelButton: true,
    confirmButtonColor: '#dc3545',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, firmar nuevamente',
    cancelButtonText: 'Cancelar'
  })

  if (result.isConfirmed) {
    savedSignature.value = null
    clearCanvas()
    showToast('info', 'Puede dibujar una nueva firma')
  }
}

// Utilidades
const formatDateTime = (dateString) => {
  if (!dateString) return 'N/A'
  try {
    const date = new Date(dateString)
    return date.toLocaleString('es-ES', {
      year: 'numeric',
      month: '2-digit',
      day: '2-digit',
      hour: '2-digit',
      minute: '2-digit'
    })
  } catch {
    return 'Fecha inválida'
  }
}

// Watchers para actualizar el estilo de dibujo
watch(lineWidth, (newWidth) => {
  if (canvasContext.value) {
    canvasContext.value.lineWidth = newWidth
  }
})

watch(lineColor, (newColor) => {
  if (canvasContext.value) {
    canvasContext.value.strokeStyle = newColor
  }
})

// Lifecycle
onMounted(() => {
  initCanvas()

  // Redimensionar canvas al cambiar tamaño de ventana
  window.addEventListener('resize', initCanvas)
})

onBeforeUnmount(() => {
  window.removeEventListener('resize', initCanvas)
})
</script>
