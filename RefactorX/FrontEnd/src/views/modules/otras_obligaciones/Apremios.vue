<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header" style="position: relative;">
      <div class="module-view-icon">
        <font-awesome-icon icon="gavel" />
      </div>
      <div class="module-view-info">
        <h1>Apremios</h1>
        <p>Otras Obligaciones - Gestión de Apremios y Diligencias</p>
      </div>
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
          @click="goBack"
          :disabled="loading"
        >
          <font-awesome-icon icon="arrow-left" />
          Salir
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <!-- Navegación de Apremios -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="list" />
            Navegación de Apremios
            <span class="badge-info" v-if="totalRecords > 0">{{ totalRecords }} registros</span>
          </h5>
          <div v-if="loading" class="spinner-border" role="status">
            <span class="visually-hidden">Cargando...</span>
          </div>
        </div>

        <div class="municipal-card-body" v-if="!loading && totalRecords > 0">
          <div class="pagination-controls">
            <div class="pagination-nav">
              <button
                class="pagination-button"
                @click="goToFirst"
                :disabled="currentIndex === 0"
                title="Primero"
              >
                <font-awesome-icon icon="angle-double-left" />
              </button>
              <button
                class="pagination-button"
                @click="goToPrevious"
                :disabled="currentIndex === 0"
                title="Anterior"
              >
                <font-awesome-icon icon="angle-left" />
              </button>
              <span class="pagination-info-text">
                Registro {{ currentIndex + 1 }} de {{ totalRecords }}
              </span>
              <button
                class="pagination-button"
                @click="goToNext"
                :disabled="currentIndex >= totalRecords - 1"
                title="Siguiente"
              >
                <font-awesome-icon icon="angle-right" />
              </button>
              <button
                class="pagination-button"
                @click="goToLast"
                :disabled="currentIndex >= totalRecords - 1"
                title="Último"
              >
                <font-awesome-icon icon="angle-double-right" />
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- Formulario de Apremio -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="edit" />
            Datos del Apremio
          </h5>
        </div>

        <div class="municipal-card-body" v-if="!loading && apremioActual">
          <form @submit.prevent="saveApremio">
            <!-- Fila 1: ZONA, FOLIO, Cve Diligencia -->
            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label">ZONA <span class="required">*</span></label>
                <input
                  type="number"
                  class="municipal-form-control"
                  v-model.number="apremioActual.zona"
                  maxlength="2"
                  required
                >
              </div>
              <div class="form-group">
                <label class="municipal-form-label">FOLIO <span class="required">*</span></label>
                <input
                  type="number"
                  class="municipal-form-control"
                  v-model.number="apremioActual.folio"
                  required
                >
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Cve Diligencia <span class="required">*</span></label>
                <input
                  type="text"
                  class="municipal-form-control"
                  v-model="apremioActual.diligencia"
                  maxlength="1"
                  required
                >
              </div>
            </div>

            <!-- Fila 2: Importes -->
            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label">$ GLOBAL</label>
                <input
                  type="number"
                  step="0.01"
                  class="municipal-form-control"
                  v-model.number="apremioActual.importe_global"
                >
              </div>
              <div class="form-group">
                <label class="municipal-form-label">$ MULTA</label>
                <input
                  type="number"
                  step="0.01"
                  class="municipal-form-control"
                  v-model.number="apremioActual.importe_multa"
                >
              </div>
              <div class="form-group">
                <label class="municipal-form-label">$ RECARGO</label>
                <input
                  type="number"
                  step="0.01"
                  class="municipal-form-control"
                  v-model.number="apremioActual.importe_recargo"
                >
              </div>
              <div class="form-group">
                <label class="municipal-form-label">$ GASTOS</label>
                <input
                  type="number"
                  step="0.01"
                  class="municipal-form-control"
                  v-model.number="apremioActual.importe_gastos"
                >
              </div>
            </div>

            <!-- Fila 3: ZONA APREMIO, FECHA EMISION, PRACTICADO -->
            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label">ZONA APREMIO</label>
                <input
                  type="number"
                  class="municipal-form-control"
                  v-model.number="apremioActual.zona_apremio"
                >
              </div>
              <div class="form-group">
                <label class="municipal-form-label">FECHA EMISION</label>
                <input
                  type="date"
                  class="municipal-form-control"
                  v-model="apremioActual.fecha_emision"
                >
              </div>
            </div>

            <!-- Fila 4: PRACTICADO (Cve - Fecha - Hora) -->
            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label">PRACTICADO (Cve)</label>
                <input
                  type="text"
                  class="municipal-form-control"
                  v-model="apremioActual.clave_practicado"
                  maxlength="1"
                >
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Fecha Practicado</label>
                <input
                  type="date"
                  class="municipal-form-control"
                  v-model="apremioActual.fecha_practicado"
                >
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Hora Practicado</label>
                <input
                  type="time"
                  class="municipal-form-control"
                  v-model="apremioActual.hora_practicado"
                >
              </div>
            </div>

            <!-- Fila 5: FECHA ENTREGA (1 y 2), CITATORIO (Fecha - Hora), EJECUTOR -->
            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label">FECHA ENTREGA 1</label>
                <input
                  type="date"
                  class="municipal-form-control"
                  v-model="apremioActual.fecha_entrega1"
                >
              </div>
              <div class="form-group">
                <label class="municipal-form-label">FECHA ENTREGA 2</label>
                <input
                  type="date"
                  class="municipal-form-control"
                  v-model="apremioActual.fecha_entrega2"
                >
              </div>
              <div class="form-group">
                <label class="municipal-form-label">CITATORIO (Fecha)</label>
                <input
                  type="date"
                  class="municipal-form-control"
                  v-model="apremioActual.fecha_citatorio"
                >
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Hora Citatorio</label>
                <input
                  type="time"
                  class="municipal-form-control"
                  v-model="apremioActual.hora"
                >
              </div>
            </div>

            <!-- Fila 6: EJECUTOR -->
            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label">EJECUTOR</label>
                <input
                  type="text"
                  class="municipal-form-control"
                  v-model="apremioActual.ejecutor"
                  maxlength="10"
                >
              </div>
            </div>

            <!-- Fila 7: CVE SECUESTRO, REMATE (Cve - Fecha), % MULTA -->
            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label">CVE SECUESTRO</label>
                <input
                  type="number"
                  class="municipal-form-control"
                  v-model.number="apremioActual.clave_secuestro"
                >
              </div>
              <div class="form-group">
                <label class="municipal-form-label">REMATE (Cve)</label>
                <input
                  type="text"
                  class="municipal-form-control"
                  v-model="apremioActual.clave_remate"
                  maxlength="1"
                >
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Fecha Remate</label>
                <input
                  type="date"
                  class="municipal-form-control"
                  v-model="apremioActual.fecha_remate"
                >
              </div>
              <div class="form-group">
                <label class="municipal-form-label">% MULTA</label>
                <input
                  type="number"
                  class="municipal-form-control"
                  v-model.number="apremioActual.porcentaje_multa"
                >
              </div>
            </div>

            <!-- Fila 8: OBSERVACIONES -->
            <div class="form-group full-width">
              <label class="municipal-form-label">Observaciones</label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="apremioActual.observaciones"
                maxlength="255"
              >
            </div>

            <!-- Botones -->
            <div class="button-group">
              <button
                type="submit"
                class="btn-municipal-primary"
                :disabled="saving"
              >
                <font-awesome-icon icon="save" />
                {{ saving ? 'Guardando...' : 'Guardar' }}
              </button>
            </div>
          </form>
        </div>

        <div class="municipal-card-body" v-else-if="!loading && !apremioActual">
          <div class="text-center text-muted">
            <font-awesome-icon icon="info-circle" size="2x" class="empty-icon" />
            <p>No se encontraron registros de apremios para este módulo y control.</p>
          </div>
        </div>
      </div>

      <!-- Tabla de Periodos Requeridos -->
      <div class="municipal-card" v-if="apremioActual">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="calendar-alt" />
            Periodos Requeridos
          </h5>
        </div>

        <div class="municipal-card-body">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Año</th>
                  <th>Periodo</th>
                  <th>Importe</th>
                  <th>Recargos</th>
                  <th>Cantidad</th>
                  <th>Tipo</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(periodo, index) in periodos" :key="index" class="row-hover">
                  <td>{{ periodo.ayo }}</td>
                  <td>{{ periodo.periodo }}</td>
                  <td class="text-right">{{ formatCurrency(periodo.importe) }}</td>
                  <td class="text-right">{{ formatCurrency(periodo.recargos) }}</td>
                  <td class="text-right">{{ periodo.cantidad }}</td>
                  <td>{{ periodo.tipo }}</td>
                </tr>
                <tr v-if="periodos.length === 0">
                  <td colspan="6" class="text-center text-muted">
                    <font-awesome-icon icon="inbox" size="2x" class="empty-icon" />
                    <p>No hay periodos requeridos para este apremio.</p>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>

      <!-- Loading overlay -->
      <div v-if="loading" class="loading-overlay">
        <div class="loading-spinner">
          <div class="spinner"></div>
          <p>Cargando apremios...</p>
        </div>
      </div>
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
    :componentName="'Apremios'"
    :moduleName="'otras_obligaciones'"
    @close="closeDocumentation"
  />
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import Swal from 'sweetalert2'

// Router
const route = useRoute()
const router = useRouter()

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

// Estado
const apremios = ref([])
const periodos = ref([])
const currentIndex = ref(0)
const totalRecords = ref(0)
const saving = ref(false)

// Parámetros del módulo (vienen de props o route params)
const par_modulo = ref(route.params.modulo || route.query.modulo || 1)
const par_control = ref(route.params.control || route.query.control || 1)

// Computed
const apremioActual = computed(() => {
  if (apremios.value.length > 0 && currentIndex.value < apremios.value.length) {
    return apremios.value[currentIndex.value]
  }
  return null
})

// Métodos de navegación
const goToFirst = () => {
  currentIndex.value = 0
  loadPeriodos()
}

const goToPrevious = () => {
  if (currentIndex.value > 0) {
    currentIndex.value--
    loadPeriodos()
  }
}

const goToNext = () => {
  if (currentIndex.value < totalRecords.value - 1) {
    currentIndex.value++
    loadPeriodos()
  }
}

const goToLast = () => {
  currentIndex.value = totalRecords.value - 1
  loadPeriodos()
}

const goBack = () => {
  router.push('/otras_obligaciones')
}

// Cargar apremios
const loadApremios = async () => {
  setLoading(true, 'Cargando apremios...')

  try {
    const response = await execute(
      'SP_APREMIOS_GET',
      'otras_obligaciones',
      [
        { nombre: 'par_modulo', valor: par_modulo.value, tipo: 'integer' },
        { nombre: 'par_control', valor: par_control.value, tipo: 'integer' }
      ],
      'guadalajara'
    )

    if (response && response.result) {
      apremios.value = response.result.map(apremio => ({
        ...apremio,
        // Convertir fechas a formato YYYY-MM-DD para inputs tipo date
        fecha_emision: formatDateForInput(apremio.fecha_emision),
        fecha_practicado: formatDateForInput(apremio.fecha_practicado),
        fecha_entrega1: formatDateForInput(apremio.fecha_entrega1),
        fecha_entrega2: formatDateForInput(apremio.fecha_entrega2),
        fecha_citatorio: formatDateForInput(apremio.fecha_citatorio),
        fecha_remate: formatDateForInput(apremio.fecha_remate),
        // Convertir hora a formato HH:MM para inputs tipo time
        hora_practicado: formatTimeForInput(apremio.hora_practicado),
        hora: formatTimeForInput(apremio.hora)
      }))
      totalRecords.value = apremios.value.length

      if (totalRecords.value > 0) {
        currentIndex.value = 0
        loadPeriodos()
        showToast('success', `${totalRecords.value} apremio(s) cargado(s)`)
      } else {
        showToast('info', 'No se encontraron apremios para este módulo y control')
      }
    } else {
      apremios.value = []
      totalRecords.value = 0
      showToast('info', 'No se encontraron registros')
    }
  } catch (error) {
    handleApiError(error)
    apremios.value = []
    totalRecords.value = 0
  } finally {
    setLoading(false)
  }
}

// Cargar periodos del apremio actual
const loadPeriodos = async () => {
  if (!apremioActual.value || !apremioActual.value.id_control) {
    periodos.value = []
    return
  }

  try {
    const response = await execute(
      'SP_PERIODOS_GET',
      'otras_obligaciones',
      [
        { nombre: 'p_id_control', valor: apremioActual.value.id_control, tipo: 'integer' }
      ],
      'guadalajara'
    )

    if (response && response.result) {
      periodos.value = response.result
    } else {
      periodos.value = []
    }
  } catch (error) {
    console.error('Error al cargar periodos:', error)
    periodos.value = []
  }
}

// Guardar apremio
const saveApremio = async () => {
  if (!apremioActual.value) {
    showToast('error', 'No hay apremio para guardar')
    return
  }

  // Validaciones
  if (!apremioActual.value.zona || !apremioActual.value.folio || !apremioActual.value.diligencia) {
    await Swal.fire({
      icon: 'warning',
      title: 'Campos requeridos',
      text: 'Por favor complete los campos obligatorios: ZONA, FOLIO y Cve Diligencia',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  // Confirmación
  const confirmResult = await Swal.fire({
    icon: 'question',
    title: '¿Confirmar guardado?',
    html: `
      <div style="text-align: left; padding: 0 20px;">
        <p style="margin-bottom: 10px;">Se guardará el apremio con los siguientes datos:</p>
        <ul style="list-style: none; padding: 0;">
          <li style="margin: 5px 0;"><strong>ZONA:</strong> ${apremioActual.value.zona}</li>
          <li style="margin: 5px 0;"><strong>FOLIO:</strong> ${apremioActual.value.folio}</li>
          <li style="margin: 5px 0;"><strong>Diligencia:</strong> ${apremioActual.value.diligencia}</li>
        </ul>
      </div>
    `,
    showCancelButton: true,
    confirmButtonColor: '#ea8215',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, guardar',
    cancelButtonText: 'Cancelar'
  })

  if (!confirmResult.isConfirmed) {
    return
  }

  saving.value = true

  try {
    // Determinar si es CREATE o UPDATE
    const isUpdate = apremioActual.value.id_control && apremioActual.value.id_control > 0
    const spName = isUpdate ? 'SP_APREMIO_UPDATE' : 'SP_APREMIO_CREATE'

    const params = [
      { nombre: 'p_id_control', valor: apremioActual.value.id_control || null, tipo: 'integer' },
      { nombre: 'p_modulo', valor: par_modulo.value, tipo: 'integer' },
      { nombre: 'p_control_otr', valor: par_control.value, tipo: 'integer' },
      { nombre: 'p_zona', valor: apremioActual.value.zona, tipo: 'integer' },
      { nombre: 'p_folio', valor: apremioActual.value.folio, tipo: 'integer' },
      { nombre: 'p_diligencia', valor: apremioActual.value.diligencia, tipo: 'string' },
      { nombre: 'p_importe_global', valor: apremioActual.value.importe_global || 0, tipo: 'decimal' },
      { nombre: 'p_importe_multa', valor: apremioActual.value.importe_multa || 0, tipo: 'decimal' },
      { nombre: 'p_importe_recargo', valor: apremioActual.value.importe_recargo || 0, tipo: 'decimal' },
      { nombre: 'p_importe_gastos', valor: apremioActual.value.importe_gastos || 0, tipo: 'decimal' },
      { nombre: 'p_zona_apremio', valor: apremioActual.value.zona_apremio || null, tipo: 'integer' },
      { nombre: 'p_fecha_emision', valor: apremioActual.value.fecha_emision || null, tipo: 'date' },
      { nombre: 'p_clave_practicado', valor: apremioActual.value.clave_practicado || null, tipo: 'string' },
      { nombre: 'p_fecha_practicado', valor: apremioActual.value.fecha_practicado || null, tipo: 'date' },
      { nombre: 'p_hora_practicado', valor: apremioActual.value.hora_practicado || null, tipo: 'time' },
      { nombre: 'p_fecha_entrega1', valor: apremioActual.value.fecha_entrega1 || null, tipo: 'date' },
      { nombre: 'p_fecha_entrega2', valor: apremioActual.value.fecha_entrega2 || null, tipo: 'date' },
      { nombre: 'p_fecha_citatorio', valor: apremioActual.value.fecha_citatorio || null, tipo: 'date' },
      { nombre: 'p_hora', valor: apremioActual.value.hora || null, tipo: 'time' },
      { nombre: 'p_ejecutor', valor: apremioActual.value.ejecutor || null, tipo: 'string' },
      { nombre: 'p_clave_secuestro', valor: apremioActual.value.clave_secuestro || null, tipo: 'integer' },
      { nombre: 'p_clave_remate', valor: apremioActual.value.clave_remate || null, tipo: 'string' },
      { nombre: 'p_fecha_remate', valor: apremioActual.value.fecha_remate || null, tipo: 'date' },
      { nombre: 'p_porcentaje_multa', valor: apremioActual.value.porcentaje_multa || null, tipo: 'integer' },
      { nombre: 'p_observaciones', valor: apremioActual.value.observaciones || null, tipo: 'string' }
    ]

    const response = await execute(
      spName,
      'otras_obligaciones',
      params,
      'guadalajara'
    )

    if (response && response.result && response.result[0]?.success) {
      await Swal.fire({
        icon: 'success',
        title: '¡Guardado exitoso!',
        text: isUpdate ? 'El apremio ha sido actualizado' : 'El apremio ha sido creado',
        confirmButtonColor: '#ea8215',
        timer: 2000
      })

      showToast('success', 'Apremio guardado correctamente')

      // Recargar datos
      loadApremios()
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
      text: 'No se pudo guardar el apremio',
      confirmButtonColor: '#ea8215'
    })
  } finally {
    saving.value = false
  }
}

// Utilidades
const formatDateForInput = (dateString) => {
  if (!dateString) return ''
  try {
    const date = new Date(dateString)
    const year = date.getFullYear()
    const month = String(date.getMonth() + 1).padStart(2, '0')
    const day = String(date.getDate()).padStart(2, '0')
    return `${year}-${month}-${day}`
  } catch (error) {
    return ''
  }
}

const formatTimeForInput = (timeString) => {
  if (!timeString) return ''
  try {
    // Si es un DateTime completo, extraer solo la hora
    const date = new Date(timeString)
    const hours = String(date.getHours()).padStart(2, '0')
    const minutes = String(date.getMinutes()).padStart(2, '0')
    return `${hours}:${minutes}`
  } catch (error) {
    return ''
  }
}

const formatCurrency = (value) => {
  if (!value) return '$0.00'
  try {
    return new Intl.NumberFormat('es-MX', {
      style: 'currency',
      currency: 'MXN'
    }).format(value)
  } catch (error) {
    return `$${value}`
  }
}

// Lifecycle
onMounted(() => {
  loadApremios()
})
</script>
