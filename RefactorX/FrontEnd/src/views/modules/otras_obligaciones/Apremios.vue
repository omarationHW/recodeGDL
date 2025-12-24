<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="gavel" />
      </div>
      <div class="module-view-info">
        <h1>Apremios</h1>
        <p>Otras Obligaciones - Gestión de Apremios y Diligencias</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-info" @click="abrirDocumentacion">
          <font-awesome-icon icon="book" />
          Documentación
        </button>
        <button class="btn-municipal-purple" @click="abrirAyuda">
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
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
      <!-- Selector de Tabla y Control -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="search" />
            Búsqueda de Apremios
          </h5>
        </div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">
                <strong>Tabla/Rubro</strong>
                <span class="required">*</span>
              </label>
              <select
                v-model="par_modulo"
                @change="onTablaChange"
                class="municipal-form-control"
                :disabled="loading"
              >
                <option value="">-- Seleccione --</option>
                <option
                  v-for="tabla in tablas"
                  :key="tabla.cve_tab"
                  :value="tabla.cve_tab"
                >
                  {{ tabla.cve_tab }} - {{ tabla.nombre }}
                </option>
              </select>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">
                <strong>Control/Expediente</strong>
                <span class="required">*</span>
              </label>
              <input
                type="text"
                v-model="par_control"
                class="municipal-form-control"
                placeholder="Número de control"
                :disabled="loading"
              />
            </div>
            <div class="form-group" style="align-self: flex-end;">
              <button
                type="button"
                class="btn-municipal-primary"
                @click="buscarApremios"
                :disabled="loading || !par_modulo || !par_control"
              >
                <font-awesome-icon icon="search" />
                Buscar
              </button>
              <button
                type="button"
                class="btn-municipal-secondary ms-2"
                @click="actualizarApremios"
                :disabled="loading || !buscado"
                title="Actualizar datos"
              >
                <font-awesome-icon icon="sync-alt" />
                Actualizar
              </button>
              <button
                type="button"
                class="btn-municipal-success ms-2"
                @click="nuevoApremio"
                :disabled="loading || !par_modulo || !par_control"
              >
                <font-awesome-icon icon="plus" />
                Nuevo
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- Panel de Estadísticas con Skeleton Loading -->
      <div class="stats-grid" v-if="loadingEstadisticas && buscado">
        <div class="stat-card stat-card-loading" v-for="n in 3" :key="`loading-${n}`">
          <div class="stat-content">
            <div class="skeleton-icon"></div>
            <div class="skeleton-number"></div>
            <div class="skeleton-label"></div>
          </div>
        </div>
      </div>

      <!-- Cards de estadísticas con datos -->
      <div class="stats-grid" v-else-if="!loadingEstadisticas && buscado && totalRecords > 0">
        <div class="stat-card stat-activos">
          <div class="stat-content">
            <div class="stat-icon">
              <font-awesome-icon icon="gavel" />
            </div>
            <h3 class="stat-number">{{ formatNumber(totalRecords) }}</h3>
            <p class="stat-label">Apremios Totales</p>
          </div>
        </div>

        <div class="stat-card stat-inactivos">
          <div class="stat-content">
            <div class="stat-icon">
              <font-awesome-icon icon="calendar-alt" />
            </div>
            <h3 class="stat-number">{{ formatNumber(periodos.length) }}</h3>
            <p class="stat-label">Periodos Requeridos</p>
          </div>
        </div>

        <div class="stat-card stat-purple">
          <div class="stat-content">
            <div class="stat-icon">
              <font-awesome-icon icon="dollar-sign" />
            </div>
            <h3 class="stat-number">{{ formatCurrency(calcularImporteTotal()) }}</h3>
            <p class="stat-label">Importe Global</p>
          </div>
        </div>
      </div>

      <!-- Navegación de Apremios -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="list" />
            Navegación de Apremios
            <span class="badge-purple ms-2" v-if="totalRecords > 0">{{ totalRecords }} registro(s)</span>
          </h5>
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
                <font-awesome-icon icon="file-alt" class="me-1" />
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
                <label class="municipal-form-label">
                  <font-awesome-icon icon="map-marker-alt" class="me-1" />
                  ZONA <span class="required">*</span>
                </label>
                <input
                  type="number"
                  class="municipal-form-control"
                  v-model.number="apremioActual.zona"
                  maxlength="2"
                  required
                >
              </div>
              <div class="form-group">
                <label class="municipal-form-label">
                  <font-awesome-icon icon="file-alt" class="me-1" />
                  FOLIO <span class="required">*</span>
                </label>
                <input
                  type="number"
                  class="municipal-form-control"
                  v-model.number="apremioActual.folio"
                  required
                >
              </div>
              <div class="form-group">
                <label class="municipal-form-label">
                  <font-awesome-icon icon="tasks" class="me-1" />
                  Cve Diligencia <span class="required">*</span>
                </label>
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
                <label class="municipal-form-label">
                  <font-awesome-icon icon="dollar-sign" class="me-1" />
                  $ GLOBAL
                </label>
                <input
                  type="number"
                  step="0.01"
                  class="municipal-form-control"
                  v-model.number="apremioActual.importe_global"
                >
              </div>
              <div class="form-group">
                <label class="municipal-form-label">
                  <font-awesome-icon icon="exclamation-triangle" class="me-1" />
                  $ MULTA
                </label>
                <input
                  type="number"
                  step="0.01"
                  class="municipal-form-control"
                  v-model.number="apremioActual.importe_multa"
                >
              </div>
              <div class="form-group">
                <label class="municipal-form-label">
                  <font-awesome-icon icon="percentage" class="me-1" />
                  $ RECARGO
                </label>
                <input
                  type="number"
                  step="0.01"
                  class="municipal-form-control"
                  v-model.number="apremioActual.importe_recargo"
                >
              </div>
              <div class="form-group">
                <label class="municipal-form-label">
                  <font-awesome-icon icon="receipt" class="me-1" />
                  $ GASTOS
                </label>
                <input
                  type="number"
                  step="0.01"
                  class="municipal-form-control"
                  v-model.number="apremioActual.importe_gastos"
                >
              </div>
            </div>

            <!-- Fila 3: ZONA APREMIO, FECHA EMISION -->
            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label">
                  <font-awesome-icon icon="map-marked-alt" class="me-1" />
                  ZONA APREMIO
                </label>
                <input
                  type="number"
                  class="municipal-form-control"
                  v-model.number="apremioActual.zona_apremio"
                >
              </div>
              <div class="form-group">
                <label class="municipal-form-label">
                  <font-awesome-icon icon="calendar" class="me-1" />
                  FECHA EMISION
                </label>
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
                <label class="municipal-form-label">
                  <font-awesome-icon icon="check-circle" class="me-1" />
                  PRACTICADO (Cve)
                </label>
                <input
                  type="text"
                  class="municipal-form-control"
                  v-model="apremioActual.clave_practicado"
                  maxlength="1"
                >
              </div>
              <div class="form-group">
                <label class="municipal-form-label">
                  <font-awesome-icon icon="calendar-check" class="me-1" />
                  Fecha Practicado
                </label>
                <input
                  type="date"
                  class="municipal-form-control"
                  v-model="apremioActual.fecha_practicado"
                >
              </div>
              <div class="form-group">
                <label class="municipal-form-label">
                  <font-awesome-icon icon="clock" class="me-1" />
                  Hora Practicado
                </label>
                <input
                  type="time"
                  class="municipal-form-control"
                  v-model="apremioActual.hora_practicado"
                >
              </div>
            </div>

            <!-- Fila 5: FECHA ENTREGA (1 y 2), CITATORIO (Fecha - Hora) -->
            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label">
                  <font-awesome-icon icon="shipping-fast" class="me-1" />
                  FECHA ENTREGA 1
                </label>
                <input
                  type="date"
                  class="municipal-form-control"
                  v-model="apremioActual.fecha_entrega1"
                >
              </div>
              <div class="form-group">
                <label class="municipal-form-label">
                  <font-awesome-icon icon="shipping-fast" class="me-1" />
                  FECHA ENTREGA 2
                </label>
                <input
                  type="date"
                  class="municipal-form-control"
                  v-model="apremioActual.fecha_entrega2"
                >
              </div>
              <div class="form-group">
                <label class="municipal-form-label">
                  <font-awesome-icon icon="envelope" class="me-1" />
                  CITATORIO (Fecha)
                </label>
                <input
                  type="date"
                  class="municipal-form-control"
                  v-model="apremioActual.fecha_citatorio"
                >
              </div>
              <div class="form-group">
                <label class="municipal-form-label">
                  <font-awesome-icon icon="clock" class="me-1" />
                  Hora Citatorio
                </label>
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
                <label class="municipal-form-label">
                  <font-awesome-icon icon="user-tie" class="me-1" />
                  EJECUTOR
                </label>
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
                <label class="municipal-form-label">
                  <font-awesome-icon icon="lock" class="me-1" />
                  CVE SECUESTRO
                </label>
                <input
                  type="number"
                  class="municipal-form-control"
                  v-model.number="apremioActual.clave_secuestro"
                >
              </div>
              <div class="form-group">
                <label class="municipal-form-label">
                  <font-awesome-icon icon="gavel" class="me-1" />
                  REMATE (Cve)
                </label>
                <input
                  type="text"
                  class="municipal-form-control"
                  v-model="apremioActual.clave_remate"
                  maxlength="1"
                >
              </div>
              <div class="form-group">
                <label class="municipal-form-label">
                  <font-awesome-icon icon="calendar-day" class="me-1" />
                  Fecha Remate
                </label>
                <input
                  type="date"
                  class="municipal-form-control"
                  v-model="apremioActual.fecha_remate"
                >
              </div>
              <div class="form-group">
                <label class="municipal-form-label">
                  <font-awesome-icon icon="percent" class="me-1" />
                  % MULTA
                </label>
                <input
                  type="number"
                  class="municipal-form-control"
                  v-model.number="apremioActual.porcentaje_multa"
                >
              </div>
            </div>

            <!-- Fila 8: OBSERVACIONES -->
            <div class="form-group full-width">
              <label class="municipal-form-label">
                <font-awesome-icon icon="comment-alt" class="me-1" />
                Observaciones
              </label>
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
              <button
                type="button"
                class="btn-municipal-secondary"
                @click="goBack"
              >
                <font-awesome-icon icon="times" />
                Cancelar
              </button>
            </div>
          </form>
        </div>

        <div class="municipal-card-body" v-else-if="!loading && !apremioActual">
          <div class="text-center text-muted">
            <font-awesome-icon icon="info-circle" size="2x" class="empty-state-icon" />
            <p>No se encontraron registros de apremios para este módulo y control.</p>
          </div>
        </div>
      </div>

      <!-- Tabla de Periodos Requeridos -->
      <div class="municipal-card" v-if="apremioActual">
        <div class="municipal-card-header">
          <div class="header-with-badge">
            <h5>
              <font-awesome-icon icon="calendar-alt" />
              Periodos Requeridos
            </h5>
            <span class="badge-purple" v-if="periodos.length > 0">
              {{ formatNumber(periodos.length) }} periodo(s)
            </span>
          </div>
        </div>

        <div class="municipal-card-body">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th class="text-center">
                    <font-awesome-icon icon="calendar" class="me-1" />
                    Año
                  </th>
                  <th class="text-center">
                    <font-awesome-icon icon="calendar-week" class="me-1" />
                    Periodo
                  </th>
                  <th class="text-end">
                    <font-awesome-icon icon="dollar-sign" class="me-1" />
                    Importe
                  </th>
                  <th class="text-end">
                    <font-awesome-icon icon="percentage" class="me-1" />
                    Recargos
                  </th>
                  <th class="text-center">
                    <font-awesome-icon icon="hashtag" class="me-1" />
                    Cantidad
                  </th>
                  <th class="text-center">
                    <font-awesome-icon icon="tag" class="me-1" />
                    Tipo
                  </th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(periodo, index) in periodos" :key="index" class="row-hover">
                  <td class="text-center">{{ periodo.ayo }}</td>
                  <td class="text-center">{{ periodo.periodo }}</td>
                  <td class="text-end">{{ formatCurrency(periodo.importe) }}</td>
                  <td class="text-end">{{ formatCurrency(periodo.recargos) }}</td>
                  <td class="text-end">{{ formatCurrency(periodo.cantidad) }}</td>
                  <td class="text-center">
                    <span class="badge badge-purple">{{ periodo.tipo }}</span>
                  </td>
                </tr>
                <tr v-if="periodos.length === 0">
                  <td colspan="6" class="text-center text-muted">
                    <font-awesome-icon icon="inbox" size="2x" class="empty-state-icon" />
                    <p>No hay periodos requeridos para este apremio.</p>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal de Ayuda y Documentación -->
    <DocumentationModal
      :show="showDocModal"
      :componentName="'Apremios'"
      :moduleName="'otras_obligaciones'"
      :docType="docType"
      :title="'Apremios - Otras Obligaciones'"
      @close="showDocModal = false"
    />

  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import Swal from 'sweetalert2'

// Router
const route = useRoute()
const router = useRouter()

// Composables
const showDocModal = ref(false)
const docType = ref('ayuda')

const abrirAyuda = () => {
  docType.value = 'ayuda'
  showDocModal.value = true
}

const abrirDocumentacion = () => {
  docType.value = 'documentacion'
  showDocModal.value = true
}

const { execute } = useApi()
const BASE_DB = 'otras_obligaciones'
const { showLoading, hideLoading } = useGlobalLoading()
const {
  showToast,
  handleApiError
} = useLicenciasErrorHandler()

// Estado local para loading
const loading = ref(false)

// Estado
const tablas = ref([])
const apremios = ref([])
const periodos = ref([])
const currentIndex = ref(0)
const totalRecords = ref(0)
const saving = ref(false)
const loadingEstadisticas = ref(false)
const buscado = ref(false)

// Parámetros del módulo
const par_modulo = ref(route.params.modulo || route.query.modulo || '')
const par_control = ref(route.params.control || route.query.control || '')

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

// Cargar módulos disponibles para apremios
const loadTablas = async () => {
  try {
    const response = await execute(
      'sp_get_modulos_apremios',
      BASE_DB,
      [],
      'guadalajara'
    )

    if (response && response.result && response.result.length > 0) {
      tablas.value = response.result.map(t => ({
        cve_tab: String(t.cve_tab).trim(),
        nombre: (t.nombre || '').trim()
      }))
    }
  } catch (error) {
    console.error('Error al cargar módulos de apremios:', error)
  }
}

// Evento al cambiar tabla
const onTablaChange = () => {
  par_control.value = ''
  apremios.value = []
  periodos.value = []
  totalRecords.value = 0
  buscado.value = false
}

// Buscar apremios
const buscarApremios = async () => {
  if (!par_modulo.value || !par_control.value) {
    showToast('warning', 'Seleccione tabla y control')
    return
  }
  buscado.value = true
  await loadApremios()
}

// Actualizar/Refrescar apremios
const actualizarApremios = async () => {
  if (buscado.value) {
    await loadApremios()
  }
}

// Crear nuevo apremio
const nuevoApremio = () => {
  if (!par_modulo.value || !par_control.value) {
    showToast('warning', 'Seleccione tabla y control primero')
    return
  }

  // Crear objeto apremio vacío
  const nuevoApr = {
    id_control: null,
    zona: null,
    folio: null,
    diligencia: '',
    importe_global: 0,
    importe_multa: 0,
    importe_recargo: 0,
    importe_gastos: 0,
    zona_apremio: null,
    fecha_emision: '',
    clave_practicado: 'P',
    fecha_practicado: '',
    hora_practicado: '',
    fecha_entrega1: '',
    fecha_entrega2: '',
    fecha_citatorio: '',
    hora: '',
    ejecutor: '',
    clave_secuestro: null,
    clave_remate: '',
    fecha_remate: '',
    porcentaje_multa: null,
    observaciones: ''
  }

  apremios.value = [nuevoApr]
  totalRecords.value = 1
  currentIndex.value = 0
  periodos.value = []
  buscado.value = true

  showToast('info', 'Complete los datos del nuevo apremio')
}

// Cargar apremios
const loadApremios = async () => {
  const startTime = performance.now()
  loading.value = true
  showLoading('Cargando apremios...')

  try {
    const response = await execute(
      'sp_get_apremios',
      BASE_DB,
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
        await loadPeriodos()
      }

      const endTime = performance.now()
      const duration = ((endTime - startTime) / 1000).toFixed(2)
      const timeMessage = duration < 1
        ? `${(duration * 1000).toFixed(0)}ms`
        : `${duration}s`

      showToast('success', `${totalRecords.value} apremio(s) cargado(s)`, timeMessage)
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
    loading.value = false
    hideLoading()
    loadingEstadisticas.value = false
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
      'sp_get_periodos_by_control',
      BASE_DB,
      [
        { nombre: 'id_control', valor: apremioActual.value.id_control, tipo: 'integer' }
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
    confirmButtonText: 'Si, guardar',
    cancelButtonText: 'Cancelar'
  })

  if (!confirmResult.isConfirmed) {
    return
  }

  const startTime = performance.now()
  saving.value = true
  showLoading('Guardando apremio...', 'Procesando información')

  try {
    // Determinar si es CREATE o UPDATE
    const isUpdate = apremioActual.value.id_control && apremioActual.value.id_control > 0
    const spName = isUpdate ? 'sp_update_apremio' : 'sp_create_apremio'

    const params = [
      { nombre: 'id_control', valor: apremioActual.value.id_control || null, tipo: 'integer' },
      { nombre: 'zona', valor: apremioActual.value.zona, tipo: 'smallint' },
      { nombre: 'folio', valor: apremioActual.value.folio, tipo: 'integer' },
      { nombre: 'diligencia', valor: apremioActual.value.diligencia, tipo: 'char' },
      { nombre: 'importe_global', valor: apremioActual.value.importe_global || 0, tipo: 'numeric' },
      { nombre: 'importe_multa', valor: apremioActual.value.importe_multa || 0, tipo: 'numeric' },
      { nombre: 'importe_recargo', valor: apremioActual.value.importe_recargo || 0, tipo: 'numeric' },
      { nombre: 'importe_gastos', valor: apremioActual.value.importe_gastos || 0, tipo: 'numeric' },
      { nombre: 'zona_apremio', valor: apremioActual.value.zona_apremio || null, tipo: 'smallint' },
      { nombre: 'fecha_emision', valor: apremioActual.value.fecha_emision || null, tipo: 'date' },
      { nombre: 'clave_practicado', valor: apremioActual.value.clave_practicado || null, tipo: 'char' },
      { nombre: 'fecha_practicado', valor: apremioActual.value.fecha_practicado || null, tipo: 'date' },
      { nombre: 'hora_practicado', valor: apremioActual.value.hora_practicado || null, tipo: 'time' },
      { nombre: 'fecha_entrega1', valor: apremioActual.value.fecha_entrega1 || null, tipo: 'date' },
      { nombre: 'fecha_entrega2', valor: apremioActual.value.fecha_entrega2 || null, tipo: 'date' },
      { nombre: 'fecha_citatorio', valor: apremioActual.value.fecha_citatorio || null, tipo: 'date' },
      { nombre: 'hora', valor: apremioActual.value.hora || null, tipo: 'time' },
      { nombre: 'ejecutor', valor: apremioActual.value.ejecutor || null, tipo: 'integer' },
      { nombre: 'clave_secuestro', valor: apremioActual.value.clave_secuestro || null, tipo: 'smallint' },
      { nombre: 'clave_remate', valor: apremioActual.value.clave_remate || null, tipo: 'char' },
      { nombre: 'fecha_remate', valor: apremioActual.value.fecha_remate || null, tipo: 'date' },
      { nombre: 'porcentaje_multa', valor: apremioActual.value.porcentaje_multa || null, tipo: 'smallint' },
      { nombre: 'observaciones', valor: apremioActual.value.observaciones || null, tipo: 'varchar' },
      { nombre: 'modulo', valor: par_modulo.value, tipo: 'integer' },
      { nombre: 'control_otr', valor: par_control.value, tipo: 'integer' }
    ]

    const response = await execute(
      spName,
      BASE_DB,
      params,
      'guadalajara'
    )

    const endTime = performance.now()
    const duration = ((endTime - startTime) / 1000).toFixed(2)
    const timeMessage = duration < 1
      ? `${(duration * 1000).toFixed(0)}ms`
      : `${duration}s`

    hideLoading()

    if (response && response.result) {
      await Swal.fire({
        icon: 'success',
        title: 'Guardado exitoso!',
        text: isUpdate ? 'El apremio ha sido actualizado' : 'El apremio ha sido creado',
        confirmButtonColor: '#ea8215',
        timer: 2000
      })

      showToast('success', 'Apremio guardado correctamente', timeMessage)

      // Recargar datos
      await loadApremios()
    } else {
      await Swal.fire({
        icon: 'error',
        title: 'Error al guardar',
        text: 'Error desconocido',
        confirmButtonColor: '#ea8215'
      })
    }
  } catch (error) {
    hideLoading()
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

const formatNumber = (num) => {
  return new Intl.NumberFormat('es-MX').format(num)
}

const calcularImporteTotal = () => {
  if (!apremioActual.value) return 0
  return apremioActual.value.importe_global || 0
}

// Lifecycle
onMounted(async () => {
  await loadTablas()
  // Si vienen parámetros en la ruta, buscar automáticamente
  if (par_modulo.value && par_control.value) {
    buscado.value = true
    await loadApremios()
  }
})
</script>
