<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="key" />
      </div>
      <div class="module-view-info">
        <h1>Cambio de Password (SVN)</h1>
        <p>Cambio de contraseña para usuarios del sistema</p>
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
        <button class="btn-municipal-primary" @click="reload">
          <font-awesome-icon icon="sync-alt" />
          Actualizar
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <!-- Formulario de cambio de contraseña -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="key" />
            Cambiar Password
          </h5>
        </div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Usuario</label>
              <input
                class="municipal-form-control"
                v-model="form.usuario"
                placeholder="Nombre de usuario"
                @keyup.enter="cambiar"
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Password Actual</label>
              <input
                class="municipal-form-control"
                v-model="form.password_actual"
                type="password"
                placeholder="Contraseña actual"
                @keyup.enter="cambiar"
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Nuevo Password</label>
              <input
                class="municipal-form-control"
                v-model="form.password_nuevo"
                type="password"
                placeholder="Nueva contraseña (mín. 6 caracteres)"
                @keyup.enter="cambiar"
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Confirmar Password</label>
              <input
                class="municipal-form-control"
                v-model="form.password_confirmar"
                type="password"
                placeholder="Confirmar nueva contraseña"
                @keyup.enter="cambiar"
              />
            </div>
          </div>
          <div class="button-group">
            <button
              class="btn-municipal-primary"
              :disabled="!usuarioComputed || !passwordActualComputed || !passwordNuevoComputed || !passwordConfirmarComputed"
              @click="cambiar"
            >
              <font-awesome-icon icon="key" />
              Cambiar Password
            </button>
          </div>
        </div>
      </div>

      <!-- Historial de cambios -->
      <div class="municipal-card">
        <div class="municipal-card-header header-with-badge">
          <h5>
            <font-awesome-icon icon="list" />
            Historial de Cambios
          </h5>
          <div class="header-right">
            <span class="badge-purple" v-if="rows.length > 0">
              {{ formatNumber(totalResultados) }} registros
            </span>
          </div>
        </div>

        <div class="municipal-card-body table-container">
          <!-- Empty State - Sin búsqueda -->
          <div v-if="rows.length === 0 && !hasSearched" class="empty-state">
            <div class="empty-state-icon">
              <font-awesome-icon icon="history" size="3x" />
            </div>
            <h4>Historial de Cambios de Contraseña</h4>
            <p>El historial se cargará automáticamente al iniciar el módulo</p>
          </div>

          <!-- Empty State - Sin resultados -->
          <div v-else-if="rows.length === 0 && hasSearched" class="empty-state">
            <div class="empty-state-icon">
              <font-awesome-icon icon="inbox" size="3x" />
            </div>
            <h4>Sin resultados</h4>
            <p>No se encontraron registros de cambios de contraseña</p>
          </div>

          <!-- Tabla con datos -->
          <div v-else class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th v-for="c in cols" :key="c">{{ formatLabel(c) }}</th>
                </tr>
              </thead>
              <tbody>
                <tr
                  v-for="(r, i) in paginatedRows"
                  :key="i"
                  @click="selectedRow = r"
                  :class="{ 'table-row-selected': selectedRow === r }"
                  class="row-hover"
                >
                  <td v-for="c in cols" :key="c">{{ formatValue(r[c]) }}</td>
                </tr>
              </tbody>
            </table>
          </div>

          <!-- Paginación -->
          <div v-if="rows.length > 0" class="pagination-controls">
            <div class="pagination-info">
              <span class="text-muted">
                Mostrando {{ ((currentPage - 1) * itemsPerPage) + 1 }}
                a {{ Math.min(currentPage * itemsPerPage, totalResultados) }}
                de {{ formatNumber(totalResultados) }} registros
              </span>
            </div>

            <div class="pagination-size">
              <label class="municipal-form-label me-2">Registros por página:</label>
              <select
                class="municipal-form-control form-control-sm"
                :value="itemsPerPage"
                @change="changePageSize($event.target.value)"
                style="width: auto; display: inline-block;"
              >
                <option value="10">10</option>
                <option value="25">25</option>
                <option value="50">50</option>
                <option value="100">100</option>
              </select>
            </div>

            <div class="pagination-buttons">
              <button class="btn-municipal-secondary btn-sm" @click="goToPage(1)" :disabled="currentPage === 1">
                <font-awesome-icon icon="angle-double-left" />
              </button>
              <button class="btn-municipal-secondary btn-sm" @click="goToPage(currentPage - 1)" :disabled="currentPage === 1">
                <font-awesome-icon icon="angle-left" />
              </button>
              <button
                v-for="page in visiblePages"
                :key="page"
                class="btn-sm"
                :class="page === currentPage ? 'btn-municipal-primary' : 'btn-municipal-secondary'"
                @click="goToPage(page)"
              >
                {{ page }}
              </button>
              <button class="btn-municipal-secondary btn-sm" @click="goToPage(currentPage + 1)" :disabled="currentPage === totalPages">
                <font-awesome-icon icon="angle-right" />
              </button>
              <button class="btn-municipal-secondary btn-sm" @click="goToPage(totalPages)" :disabled="currentPage === totalPages">
                <font-awesome-icon icon="angle-double-right" />
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- Toast Notifications -->
      <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
        <div class="toast-content">
          <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
          <span class="toast-message">{{ toast.message }}</span>
        </div>
        <span v-if="toast.duration" class="toast-duration">{{ toast.duration }}</span>
        <button class="toast-close" @click="hideToast">
          <font-awesome-icon icon="times" />
        </button>
      </div>

      <!-- Modal de Ayuda y Documentación -->
      <DocumentationModal
        :show="showDocModal"
        :componentName="'sfrm_chgpass'"
        :moduleName="'estacionamiento_exclusivo'"
        :docType="docType"
        :title="'Cambio de Password'"
        @close="showDocModal = false"
      />
    </div>
    <!-- /module-view-content -->
  </div>
  <!-- /module-view -->
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import Swal from 'sweetalert2'

// Documentación y Ayuda
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

const BASE_DB = 'padron_licencias'
const BASE_SCHEMA = 'publico'
const OP_CHGPASS = 'sp_change_user_password'
const OP_QUERY = 'sp_passwords_list'

const { execute } = useApi()
const {
  toast,
  showToast,
  hideToast,
  getToastIcon,
  handleApiError
} = useLicenciasErrorHandler()

const { showLoading, hideLoading } = useGlobalLoading()

// Estado
const form = ref({ usuario: '', password_actual: '', password_nuevo: '', password_confirmar: '' })
const rows = ref([])
const cols = ref([])
const selectedRow = ref(null)
const hasSearched = ref(false)
const currentPage = ref(1)
const itemsPerPage = ref(25)

const usuarioComputed = computed(() => form.value.usuario || null)
const passwordActualComputed = computed(() => form.value.password_actual || null)
const passwordNuevoComputed = computed(() => form.value.password_nuevo || null)
const passwordConfirmarComputed = computed(() => form.value.password_confirmar || null)
const totalResultados = computed(() => rows.value.length)
const totalPages = computed(() => Math.ceil(totalResultados.value / itemsPerPage.value))
const paginatedRows = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage.value
  return rows.value.slice(start, start + itemsPerPage.value)
})
const visiblePages = computed(() => {
  const pages = []
  const maxVisible = 5
  let startPage = Math.max(1, currentPage.value - Math.floor(maxVisible / 2))
  let endPage = Math.min(totalPages.value, startPage + maxVisible - 1)
  if (endPage - startPage < maxVisible - 1) {
    startPage = Math.max(1, endPage - maxVisible + 1)
  }
  for (let i = startPage; i <= endPage; i++) {
    pages.push(i)
  }
  return pages
})

const goToPage = (page) => {
  if (page < 1 || page > totalPages.value) return
  currentPage.value = page
  selectedRow.value = null
}

const changePageSize = (size) => {
  itemsPerPage.value = parseInt(size)
  currentPage.value = 1
  selectedRow.value = null
}

const reload = async () => {
  showLoading('Cargando historial...', 'Contraseñas')
  hasSearched.value = true
  selectedRow.value = null
  currentPage.value = 1
  const t0 = performance.now()
  try {
    const response = await execute(OP_QUERY, BASE_DB, [])
    let arr = []
    if (response && response.data) {
      arr = Array.isArray(response.data) ? response.data : []
    } else if (response && response.result) {
      arr = Array.isArray(response.result) ? response.result : []
    }
    rows.value = arr
    cols.value = arr.length ? Object.keys(arr[0]) : []
    const dur = performance.now() - t0
    const txt = dur < 1000 ? `${Math.round(dur)}ms` : `${(dur / 1000).toFixed(2)}s`
    toast.value.duration = txt
    showToast('success', `${rows.value.length} registro(s) cargados`)
  } catch (e) {
    rows.value = []
    cols.value = []
    handleApiError(e)
  } finally {
    hideLoading()
  }
}

const cambiar = async () => {
  if (!usuarioComputed.value || !passwordActualComputed.value || !passwordNuevoComputed.value) {
    showToast('error', 'Debe completar todos los campos')
    return
  }
  if (passwordNuevoComputed.value !== passwordConfirmarComputed.value) {
    showToast('error', 'Las contraseñas no coinciden')
    return
  }
  if (passwordNuevoComputed.value.length < 6 || passwordNuevoComputed.value.length > 8) {
    showToast('error', 'La contraseña debe tener entre 6 y 8 caracteres')
    return
  }
  const confirmResult = await Swal.fire({
    title: '¿Confirmar cambio de contraseña?',
    text: `Cambiar contraseña del usuario ${usuarioComputed.value}`,
    icon: 'question',
    showCancelButton: true,
    confirmButtonText: 'Sí, cambiar',
    cancelButtonText: 'Cancelar'
  })
  if (!confirmResult.isConfirmed) return

  showLoading('Cambiando contraseña...', 'Procesando')
  const t0 = performance.now()
  try {
    const response = await execute(OP_CHGPASS, BASE_DB, [
      { name: 'p_username', type: 'C', value: String(usuarioComputed.value) },
      { name: 'p_current_password', type: 'C', value: String(passwordActualComputed.value) },
      { name: 'p_new_password', type: 'C', value: String(passwordNuevoComputed.value) }
    ])
    let resultData = {}
    if (response && response.data && Array.isArray(response.data)) {
      resultData = response.data[0] || {}
    } else if (response && response.result && Array.isArray(response.result)) {
      resultData = response.result[0] || {}
    }
    const mensaje = resultData?.message || 'Contraseña actualizada'
    const icono = resultData?.success ? 'success' : 'error'
    const dur = performance.now() - t0
    const txt = dur < 1000 ? `${Math.round(dur)}ms` : `${(dur / 1000).toFixed(2)}s`
    toast.value.duration = txt
    await Swal.fire({
      title: resultData?.success ? '¡Éxito!' : 'Error',
      text: mensaje,
      icon: icono,
      confirmButtonText: 'OK'
    })
    if (resultData?.success) {
      form.value = { usuario: '', password_actual: '', password_nuevo: '', password_confirmar: '' }
      reload()
    }
  } catch (e) {
    handleApiError(e)
  } finally {
    hideLoading()
  }
}

// Utilidades
const formatNumber = (n) => new Intl.NumberFormat('es-MX').format(n)
const formatLabel = (k) => k.replace(/_/g, ' ').replace(/([A-Z])/g, ' $1').replace(/^./, s => s.toUpperCase()).trim()
const formatValue = (v) => v === null || v === undefined ? '-' : typeof v === 'boolean' ? (v ? 'Sí' : 'No') : String(v)

onMounted(() => reload())
</script>
