<template>
  <div class="module-view">
    <!-- Toast Notification -->
    <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
      <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
      <span class="toast-message">{{ toast.message }}</span>
      <button class="toast-close" @click="hideToast"><font-awesome-icon icon="times" /></button>
    </div>

    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="city" /></div>
      <div class="module-view-info">
        <h1>Estado Municipal — Estacionamientos</h1>
        <p>Remesas y operaciones</p>
      </div>
      <div class="button-group ms-auto">
        <button
          class="btn-municipal-secondary"
          @click="mostrarDocumentacion"
          title="Documentacion Tecnica"
        >
          <font-awesome-icon icon="file-code" />
          Documentacion
        </button>
        <button
          class="btn-municipal-purple"
          @click="openDocumentation"
          title="Ayuda"
        >
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
      </div>

      <div class="module-view-actions">
        <button class="btn-municipal-secondary" :disabled="loadingRemesas" @click="loadRemesas"><font-awesome-icon icon="sync-alt" /> Remesas</button>
      </div>
    </div>
    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>Remesas recientes</h5>
          <div v-if="loadingRemesas" class="spinner-border" role="status"></div>
        </div>
        <div class="municipal-card-body table-container" v-if="!loadingRemesas">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Remesa</th>
                  <th>Fecha</th>
                  <th>Aplica Tesorería</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="r in paginatedRemesas" :key="r.remesa">
                  <td>{{ r.remesa }}</td>
                  <td>{{ formatDate(r.fecharemesa) }}</td>
                  <td>{{ formatDate(r.aplicadoteso) }}</td>
                </tr>
                <tr v-if="remesas.length===0">
                  <td colspan="3">
                    <div class="empty-table-state">
                      <font-awesome-icon icon="inbox" class="empty-table-icon" />
                      <p class="empty-table-text">No hay remesas registradas</p>
                      <small class="empty-table-hint">Haga clic en "Remesas" para actualizar</small>
                    </div>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>

          <!-- Paginación -->
          <div class="pagination-container" v-if="remesas.length > 0">
            <div class="pagination-info">
              Mostrando {{ startIndex + 1 }} a {{ endIndex }} de {{ remesas.length }} registros
            </div>
            <div class="pagination-controls">
              <button
                class="btn-pagination"
                :disabled="currentPage === 1"
                @click="currentPage = 1"
              >
                <font-awesome-icon icon="angles-left" />
              </button>
              <button
                class="btn-pagination"
                :disabled="currentPage === 1"
                @click="currentPage--"
              >
                <font-awesome-icon icon="angle-left" />
              </button>
              <span class="pagination-page">Página {{ currentPage }} de {{ totalPages }}</span>
              <button
                class="btn-pagination"
                :disabled="currentPage === totalPages"
                @click="currentPage++"
              >
                <font-awesome-icon icon="angle-right" />
              </button>
              <button
                class="btn-pagination"
                :disabled="currentPage === totalPages"
                @click="currentPage = totalPages"
              >
                <font-awesome-icon icon="angles-right" />
              </button>
            </div>
            <div class="pagination-size">
              <label>Registros por página:</label>
              <select v-model.number="pageSize" class="form-select form-select-sm">
                <option :value="10">10</option>
                <option :value="25">25</option>
                <option :value="50">50</option>
                <option :value="100">100</option>
              </select>
            </div>
          </div>
        </div>
      </div>

      <div class="municipal-card">
        <div class="municipal-card-header"><h5>Operación spd_delesta01</h5></div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group"><label class="municipal-form-label">Año</label><input type="number" class="municipal-form-control" v-model.number="form.axo" /></div>
            <div class="form-group"><label class="municipal-form-label">Folio</label><input type="number" class="municipal-form-control" v-model.number="form.folio" /></div>
            <div class="form-group"><label class="municipal-form-label">Placa</label><input class="municipal-form-control" v-model="form.placa" /></div>
            <div class="form-group"><label class="municipal-form-label">Convenio</label><input type="number" class="municipal-form-control" v-model.number="form.convenio" /></div>
            <div class="form-group"><label class="municipal-form-label">Fecha</label><input type="date" class="municipal-form-control" v-model="form.fecha" /></div>
            <div class="form-group"><label class="municipal-form-label">Reca</label><input type="number" class="municipal-form-control" v-model.number="form.reca" /></div>
            <div class="form-group"><label class="municipal-form-label">Caja</label><input class="municipal-form-control" v-model="form.caja" /></div>
            <div class="form-group"><label class="municipal-form-label">Oper</label><input type="number" class="municipal-form-control" v-model.number="form.oper" /></div>
            <div class="form-group"><label class="municipal-form-label">UsuAuto</label><input type="number" class="municipal-form-control" v-model.number="form.usuauto" /></div>
            <div class="form-group"><label class="municipal-form-label">Opc</label><input type="number" class="municipal-form-control" v-model.number="form.opc" /></div>
          </div>
          <div class="button-group"><button class="btn-municipal-primary" :disabled="loadingOp" @click="ejecutarOp"><font-awesome-icon icon="play" /> Ejecutar</button></div>
          <div v-if="loadingOp" class="spinner-border" role="status"></div>
          <p v-if="opMsg" class="text-muted">{{ opMsg }}</p>
        </div>
      </div>
    </div>

    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showDocumentation"
      @close="closeDocumentation"
      title="Ayuda - EstadoMpioPublicos"
    >
      <h3>Estado Mpio Publicos</h3>
      <p>Documentacion del modulo Estacionamiento Publico.</p>
    </DocumentationModal>

    <!-- Modal de Documentacion Tecnica -->
    <TechnicalDocsModal
      :show="showTechDocs"
      :componentName="'EstadoMpioPublicos'"
      :moduleName="'estacionamiento_publico'"
      @close="closeTechDocs"
    />

  </div>
</template>

<script setup>
import TechnicalDocsModal from '@/components/common/TechnicalDocsModal.vue'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { ref, reactive, onMounted, computed, watch, nextTick } from 'vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import Swal from 'sweetalert2'

const BASE_DB = 'estacionamiento_publico'
const SCHEMA = 'public'
const { loading, execute } = useApi()
const { toast, showToast, hideToast, getToastIcon, handleApiError } = useLicenciasErrorHandler()
const { showLoading, hideLoading } = useGlobalLoading()

const remesas = ref([])
const loadingRemesas = ref(false)
const loadingOp = ref(false)
const opMsg = ref('')

// Paginación
const currentPage = ref(1)
const pageSize = ref(25)

const form = reactive({
  axo: new Date().getFullYear(),
  folio: 0,
  placa: '',
  convenio: 0,
  fecha: new Date().toISOString().split('T')[0],
  reca: 0,
  caja: '',
  oper: 0,
  usuauto: 0,
  opc: 1
})

// Computed para paginación
const totalPages = computed(() => Math.ceil(remesas.value.length / pageSize.value))
const startIndex = computed(() => (currentPage.value - 1) * pageSize.value)
const endIndex = computed(() => Math.min(startIndex.value + pageSize.value, remesas.value.length))
const paginatedRemesas = computed(() => {
  return remesas.value.slice(startIndex.value, endIndex.value)
})

// Watch para resetear página cuando cambia el tamaño
watch(pageSize, () => {
  currentPage.value = 1
})

function formatDate(d) {
  if (!d) return '—'
  return new Date(d).toLocaleDateString('es-MX')
}

async function loadRemesas() {
  showLoading('Cargando...', 'Obteniendo remesas')
  loadingRemesas.value = true
  remesas.value = []
  currentPage.value = 1
  try {
    const resp = await execute('sp_get_remesas_estado_mpio', BASE_DB, [], '', null, SCHEMA)
    const data = resp?.result || resp?.data?.result || resp?.data || []
    remesas.value = Array.isArray(data) ? data : []

    if (remesas.value.length === 0) {
      showToast('info', 'No se encontraron remesas recientes')
    }
  } catch (e) {
    handleApiError(e)
    remesas.value = []
  } finally {
    loadingRemesas.value = false
    hideLoading()
  }
}

async function ejecutarOp() {
  if (!form.axo || !form.folio) {
    showToast('warning', 'Año y Folio son requeridos')
    return
  }

  // Confirmación con SweetAlert2
  const confirmacion = await Swal.fire({
    icon: 'question',
    title: 'Confirmar Operación',
    html: `<p>¿Ejecutar operación <strong>spd_delesta01</strong>?</p>
      <ul class="swal-list-left">
        <li><strong>Año:</strong> ${form.axo}</li>
        <li><strong>Folio:</strong> ${form.folio}</li>
        <li><strong>Placa:</strong> ${form.placa || '—'}</li>
        <li><strong>Fecha:</strong> ${form.fecha}</li>
      </ul>`,
    showCancelButton: true,
    confirmButtonColor: '#ea8215',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, ejecutar',
    cancelButtonText: 'Cancelar'
  })

  if (!confirmacion.isConfirmed) return

  showLoading('Ejecutando...', 'Procesando operación')
  loadingOp.value = true
  opMsg.value = ''
  try {
    const params = [
      { nombre: 'axo', valor: form.axo, tipo: 'integer' },
      { nombre: 'folio', valor: form.folio, tipo: 'integer' },
      { nombre: 'placa', valor: form.placa.toUpperCase(), tipo: 'string' },
      { nombre: 'convenio', valor: form.convenio || 0, tipo: 'integer' },
      { nombre: 'fecha', valor: form.fecha, tipo: 'date' },
      { nombre: 'reca', valor: form.reca || 0, tipo: 'integer' },
      { nombre: 'caja', valor: form.caja || '', tipo: 'string' },
      { nombre: 'oper', valor: form.oper || 0, tipo: 'integer' },
      { nombre: 'usuauto', valor: form.usuauto || 0, tipo: 'integer' },
      { nombre: 'opc', valor: form.opc || 1, tipo: 'integer' }
    ]
    const resp = await execute('spd_delesta01', BASE_DB, params, '', null, SCHEMA)
    const data = resp?.result?.[0] || resp?.data?.result?.[0] || {}

    if (resp?.success !== false) {
      opMsg.value = data?.message || 'Operación ejecutada correctamente'

      hideLoading()
      await nextTick()
      await Swal.fire({
        icon: 'success',
        title: 'Operación Exitosa',
        text: opMsg.value,
        timer: 2500,
        timerProgressBar: true,
        showConfirmButton: false
      })
    } else {
      opMsg.value = data?.message || 'Error en operación'
      hideLoading()
      await nextTick()
      await Swal.fire({
        icon: 'error',
        title: 'Error',
        text: opMsg.value,
        confirmButtonColor: '#ea8215'
      })
    }
  } catch (e) {
    handleApiError(e)
    opMsg.value = e.message || 'Error en operación'
    hideLoading()
  } finally {
    loadingOp.value = false
  }
}

onMounted(() => {
  loadRemesas()
})

// Documentacion y Ayuda
const showDocumentation = ref(false)
const openDocumentation = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false
const showTechDocs = ref(false)
const mostrarDocumentacion = () => showTechDocs.value = true
const closeTechDocs = () => showTechDocs.value = false

</script>

