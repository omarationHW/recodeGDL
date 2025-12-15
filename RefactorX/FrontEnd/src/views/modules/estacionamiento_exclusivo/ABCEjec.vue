<template>
  <div class="module-view module-layout">
    <!-- ========== HEADER ========== -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="users" />
      </div>
      <div class="module-view-info">
        <h1>Captura de Ejecutores</h1>
        <p>Alta, Baja y Modificación de ejecutores de cobranza coactiva</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-primary" @click="reload">
          <font-awesome-icon icon="sync-alt" />
          Actualizar
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <!-- ========== PANEL BÚSQUEDA EJECUTOR ========== -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="search" />
            Buscar Ejecutor
          </h5>
        </div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Numero Ejecutor</label>
              <input
                type="number"
                class="municipal-form-control"
                v-model.number="cveEjecutor"
                @keyup.enter="buscarEjecutor"
                placeholder="Ingrese número de ejecutor"
                :disabled="loading"
              />
            </div>
            <div class="form-group" v-if="tienePermiso">
              <label class="municipal-form-label">Recaudadora</label>
              <select class="municipal-form-control" v-model="idRecSeleccionado" @change="onRecaudadoraChange">
                <option v-for="rec in recaudadoras" :key="rec.id_rec" :value="rec.id_rec">
                  {{ rec.id_rec }} - {{ rec.recaudadora || rec.nombre }}
                </option>
              </select>
            </div>
            <div class="form-group" v-else>
              <label class="municipal-form-label">Recaudadora</label>
              <input type="text" class="municipal-form-control" :value="idRecUsuario" disabled />
            </div>
          </div>
          <div class="button-group">
            <button class="btn-municipal-primary" @click="buscarEjecutor" :disabled="loading || !cveEjecutor">
              <font-awesome-icon icon="search" />
              Buscar
            </button>
          </div>
        </div>
      </div>

      <!-- ========== MODAL DATOS EJECUTOR ========== -->
      <div class="modal fade show" v-if="showFormulario" style="display: block; background: rgba(0,0,0,0.5);" @click.self="cerrarFormulario">
        <div class="modal-dialog modal-lg modal-dialog-centered">
          <div class="modal-content">
            <div class="modal-header bg-primary text-white">
              <h5 class="modal-title">
                <font-awesome-icon icon="user-edit" class="me-2" />
                {{ ejecutorExiste ? 'Editar Ejecutor' : 'Nuevo Ejecutor' }}
                <span class="badge ms-2" :class="ejecutorExiste ? (!ejecutorActivo ? 'bg-danger' : 'bg-success') : 'bg-warning'">
                  {{ ejecutorExiste ? (!ejecutorActivo ? 'BAJA' : 'ACTIVO') : 'NUEVO' }}
                </span>
              </h5>
              <button type="button" class="btn-close btn-close-white" @click="cerrarFormulario"></button>
            </div>
            <div class="modal-body">
              <!-- Clave Ejecutor (solo lectura) -->
              <div class="form-row mb-3">
                <div class="form-group">
                  <label class="municipal-form-label">Clave Ejecutor</label>
                  <input type="text" class="municipal-form-control" :value="cveEjecutor" disabled />
                </div>
                <div class="form-group">
                  <label class="municipal-form-label">Recaudadora</label>
                  <input type="text" class="municipal-form-control" :value="idRecActual" disabled />
                </div>
              </div>

              <!-- Nombre -->
              <div class="form-row mb-3">
                <div class="form-group" style="flex: 1;">
                  <label class="municipal-form-label required">Nombre</label>
                  <input
                    type="text"
                    class="municipal-form-control"
                    v-model="form.nombre"
                    maxlength="60"
                    style="text-transform: uppercase;"
                    ref="inputNombre"
                  />
                </div>
              </div>

              <!-- RFC -->
              <div class="form-row mb-3">
                <div class="form-group">
                  <label class="municipal-form-label required">R.F.C. (Iniciales)</label>
                  <input
                    type="text"
                    class="municipal-form-control"
                    v-model="form.ini_rfc"
                    maxlength="4"
                    style="text-transform: uppercase;"
                    placeholder="XXXX"
                  />
                </div>
                <div class="form-group">
                  <label class="municipal-form-label required">Fecha Nac. RFC</label>
                  <input
                    type="date"
                    class="municipal-form-control"
                    v-model="form.fec_rfc"
                  />
                </div>
                <div class="form-group">
                  <label class="municipal-form-label required">Homoclave</label>
                  <input
                    type="text"
                    class="municipal-form-control"
                    v-model="form.hom_rfc"
                    maxlength="3"
                    style="text-transform: uppercase;"
                    placeholder="XXX"
                  />
                </div>
              </div>

              <!-- Oficio -->
              <div class="form-row mb-3">
                <div class="form-group">
                  <label class="municipal-form-label required">Oficio</label>
                  <input
                    type="text"
                    class="municipal-form-control"
                    v-model="form.oficio"
                    maxlength="14"
                  />
                </div>
              </div>

              <!-- Fechas -->
              <div class="form-row mb-3">
                <div class="form-group">
                  <label class="municipal-form-label required">Fecha Inicio</label>
                  <input
                    type="date"
                    class="municipal-form-control"
                    v-model="form.fecinic"
                  />
                </div>
                <div class="form-group">
                  <label class="municipal-form-label required">Fecha Término</label>
                  <input
                    type="date"
                    class="municipal-form-control"
                    v-model="form.fecterm"
                  />
                </div>
              </div>
            </div>
            <div class="modal-footer">
              <button
                class="btn btn-success"
                @click="guardarEjecutor"
                :disabled="saving"
              >
                <font-awesome-icon :icon="ejecutorExiste ? 'save' : 'plus'" class="me-1" />
                {{ ejecutorExiste ? (!ejecutorActivo ? 'Reactivar y Guardar' : 'Guardar') : 'Crear' }}
              </button>

              <button
                class="btn btn-danger"
                @click="toggleVigencia"
                v-if="ejecutorExiste && ejecutorActivo"
                :disabled="saving"
              >
                <font-awesome-icon icon="ban" class="me-1" />
                Dar de Baja
              </button>

              <button class="btn btn-secondary" @click="cerrarFormulario">
                <font-awesome-icon icon="times" class="me-1" />
                Cancelar
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- ========== TABLA DE EJECUTORES ========== -->
      <div class="municipal-card">
        <div class="municipal-card-header clickable-header" @click="toggleTabla">
          <div class="header-with-badge">
            <h5>
              <font-awesome-icon icon="list" />
              Listado de Ejecutores
              <font-awesome-icon :icon="showTabla ? 'chevron-up' : 'chevron-down'" class="ms-2" />
            </h5>
            <span class="badge badge-purple" v-if="totalRegistros > 0">
              {{ totalRegistros }} registros
            </span>
          </div>
          <div v-if="loading" class="spinner-border spinner-border-sm text-primary" role="status">
            <span class="visually-hidden">Cargando...</span>
          </div>
        </div>

        <div class="municipal-card-body table-container" v-show="showTabla">
          <!-- Filtro de búsqueda -->
          <div class="form-row mb-3">
            <div class="form-group">
              <input
                type="text"
                class="municipal-form-control"
                v-model="filtroTexto"
                @keyup.enter="buscarEnTabla"
                placeholder="Buscar por nombre o clave..."
              />
            </div>
            <div class="form-group">
              <select class="municipal-form-control" v-model="filtroVigencia" @change="buscarEnTabla">
                <option value="">Todos</option>
                <option value="A">Activos</option>
                <option value="B">Bajas</option>
              </select>
            </div>
            <div class="form-group">
              <button class="btn-municipal-secondary" @click="buscarEnTabla">
                <font-awesome-icon icon="search" />
                Buscar
              </button>
            </div>
          </div>

          <div v-if="rows.length === 0 && !loading" class="empty-state">
            <font-awesome-icon icon="inbox" size="3x" class="empty-icon" />
            <p>No hay ejecutores para mostrar</p>
          </div>

          <div v-else class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Clave</th>
                  <th>Nombre</th>
                  <th>RFC</th>
                  <th>Oficio</th>
                  <th>Fec. Inicio</th>
                  <th>Fec. Término</th>
                  <th>Vigencia</th>
                  <th class="text-center" style="width: 100px;">Acciones</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="r in rows" :key="r.cve_eje" class="clickable-row" @dblclick="seleccionarEjecutor(r)">
                  <td><code>{{ r.cve_eje }}</code></td>
                  <td>{{ r.nombre }}</td>
                  <td>{{ formatRFC(r) }}</td>
                  <td>{{ r.oficio || '-' }}</td>
                  <td>{{ formatDate(r.fecinic) }}</td>
                  <td>{{ formatDate(r.fecterm) }}</td>
                  <td>
                    <span class="badge" :class="r.vigencia === 'B' ? 'badge-danger' : 'badge-success'">
                      {{ r.vigencia === 'B' ? 'Baja' : 'Activo' }}
                    </span>
                  </td>
                  <td class="text-center">
                    <button
                      class="btn-municipal-info btn-sm"
                      @click.stop="seleccionarEjecutor(r)"
                      title="Editar ejecutor"
                    >
                      <font-awesome-icon icon="edit" />
                    </button>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>

          <!-- Paginación -->
          <div class="pagination-container" v-if="totalRegistros > 0">
            <div class="pagination-info">
              Mostrando {{ paginaActual * registrosPorPagina + 1 }} - {{ Math.min((paginaActual + 1) * registrosPorPagina, totalRegistros) }} de {{ totalRegistros }}
            </div>
            <div class="pagination-controls">
              <select class="municipal-form-control pagination-select" v-model.number="registrosPorPagina" @change="cambiarRegistrosPorPagina">
                <option :value="10">10</option>
                <option :value="25">25</option>
                <option :value="50">50</option>
                <option :value="100">100</option>
              </select>
              <button class="btn btn-sm btn-outline-secondary" @click="paginaAnterior" :disabled="paginaActual === 0">
                <font-awesome-icon icon="chevron-left" />
              </button>
              <span class="pagination-page">
                Página {{ paginaActual + 1 }} de {{ totalPaginas }}
              </span>
              <button class="btn btn-sm btn-outline-secondary" @click="paginaSiguiente" :disabled="paginaActual >= totalPaginas - 1">
                <font-awesome-icon icon="chevron-right" />
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showDocumentation"
      @close="closeDocumentation"
      title="Ayuda - ABCEjec"
    >
      <h3>Captura de Ejecutores</h3>
      <p>Este módulo permite gestionar el catálogo de ejecutores de cobranza coactiva.</p>
      <h4>Funcionalidades:</h4>
      <ul>
        <li><strong>Alta:</strong> Registrar un nuevo ejecutor ingresando su número y datos.</li>
        <li><strong>Modificación:</strong> Actualizar los datos de un ejecutor existente.</li>
        <li><strong>Baja:</strong> Desactivar un ejecutor (puede reactivarse posteriormente).</li>
        <li><strong>Reactivación:</strong> Volver a activar un ejecutor dado de baja.</li>
      </ul>
    </DocumentationModal>

    <!-- Modal de Documentacion Tecnica -->
    <TechnicalDocsModal
      :show="showTechDocs"
      :componentName="'ABCEjec'"
      :moduleName="'estacionamiento_exclusivo'"
      @close="closeTechDocs"
    />
  </div>
</template>

<script setup>
import TechnicalDocsModal from '@/components/common/TechnicalDocsModal.vue'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { ref, reactive, computed, onMounted, nextTick } from 'vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import Swal from 'sweetalert2'

// ========== CONSTANTES ==========
// La tabla ta_15_ejecutores está en padron_licencias.comun
const BASE_DB = 'padron_licencias'
const SCHEMA = 'publico'

// SPs para ABCEjec (en esquema comun)
const OP_LIST = 'sp_ejecutores_list'
const OP_GET = 'sp_ejecutor_get'
const OP_CREATE = 'sp_ejecutor_create'
const OP_UPDATE = 'sp_ejecutor_update'
const OP_TOGGLE = 'sp_ejecutor_toggle_vigencia'
const OP_RECAUDADORAS = 'sp_recaudadoras_list'
const OP_STATS = 'sp_ejecutores_estadisticas'

// ========== COMPOSABLES ==========
const { execute } = useApi()
const { showLoading, hideLoading } = useGlobalLoading()
const {
  showToast,
  handleApiError
} = useLicenciasErrorHandler()

// ========== ESTADO ==========
const loading = ref(false)
const saving = ref(false)
const showFormulario = ref(false)
const showTabla = ref(true)
const ejecutorExiste = ref(false)

// Datos
const rows = ref([])
const recaudadoras = ref([])
const cveEjecutor = ref(null)
const idRecUsuario = ref(1) // ID de recaudadora del usuario logueado
const idRecSeleccionado = ref(1)
const tienePermiso = ref(false) // Permiso para cambiar recaudadora

// Paginación server-side
const paginaActual = ref(0)
const registrosPorPagina = ref(10)
const totalRegistros = ref(0)
const filtroTexto = ref('')
const filtroVigencia = ref('')

// Computed para paginación
const totalPaginas = computed(() => {
  return Math.ceil(totalRegistros.value / registrosPorPagina.value) || 1
})

// Ejecutor actual
const ejecutor = reactive({
  cve_eje: null,
  nombre: '',
  ini_rfc: '',
  fec_rfc: null,
  hom_rfc: '',
  id_rec: null,
  oficio: '',
  fecinic: null,
  fecterm: null,
  vigencia: 'A'
})

// Formulario
const form = reactive({
  nombre: '',
  ini_rfc: '',
  fec_rfc: '',
  hom_rfc: '',
  oficio: '',
  fecinic: '',
  fecterm: ''
})

// Refs
const inputNombre = ref(null)

// ========== COMPUTED ==========
const idRecActual = computed(() => {
  return tienePermiso.value ? idRecSeleccionado.value : idRecUsuario.value
})

// Verificar si el ejecutor está activo (no dado de baja)
const ejecutorActivo = computed(() => {
  const vig = (ejecutor.vigencia || '').toString().trim().toUpperCase()
  return vig !== 'B'
})

// ========== FUNCIONES ==========

// Cargar recaudadoras para el combo
const cargarRecaudadoras = async () => {
  try {
    const data = await execute(OP_RECAUDADORAS, BASE_DB, [], 'guadalajara', null, SCHEMA)
    recaudadoras.value = Array.isArray(data?.rows) ? data.rows : Array.isArray(data) ? data : []

    // Si hay recaudadoras, seleccionar la del usuario
    if (recaudadoras.value.length > 0) {
      const existe = recaudadoras.value.find(r => r.id_rec === idRecUsuario.value)
      if (existe) {
        idRecSeleccionado.value = idRecUsuario.value
      } else {
        idRecSeleccionado.value = recaudadoras.value[0].id_rec
      }
    }
  } catch (error) {
    console.error('Error cargando recaudadoras:', error)
    recaudadoras.value = []
  }
}

// Cargar lista de ejecutores con paginación server-side
const cargarEjecutores = async () => {
  loading.value = true
  try {
    const offset = paginaActual.value * registrosPorPagina.value
    const params = [
      { nombre: 'p_q', tipo: 'C', valor: filtroTexto.value || '' },
      { nombre: 'p_vigencia', tipo: 'C', valor: filtroVigencia.value || '' },
      { nombre: 'p_offset', tipo: 'I', valor: offset },
      { nombre: 'p_limit', tipo: 'I', valor: registrosPorPagina.value }
    ]
    const data = await execute(OP_LIST, BASE_DB, params, 'guadalajara', null, SCHEMA)

    // Manejar diferentes estructuras de respuesta
    let resultados = []
    if (Array.isArray(data)) {
      resultados = data
    } else if (data?.rows && Array.isArray(data.rows)) {
      resultados = data.rows
    } else if (data?.data && Array.isArray(data.data)) {
      resultados = data.data
    } else if (data?.result && Array.isArray(data.result)) {
      resultados = data.result
    }

    rows.value = resultados

    // Obtener total_count del primer registro (viene del SP)
    if (resultados.length > 0 && resultados[0].total_count !== undefined) {
      totalRegistros.value = parseInt(resultados[0].total_count) || 0
    } else {
      totalRegistros.value = resultados.length
    }

  } catch (error) {
    console.error('Error cargando ejecutores:', error)
    rows.value = []
    totalRegistros.value = 0
  } finally {
    loading.value = false
  }
}

// Funciones de paginación
const paginaAnterior = () => {
  if (paginaActual.value > 0) {
    paginaActual.value--
    cargarEjecutores()
  }
}

const paginaSiguiente = () => {
  if (paginaActual.value < totalPaginas.value - 1) {
    paginaActual.value++
    cargarEjecutores()
  }
}

const cambiarRegistrosPorPagina = () => {
  paginaActual.value = 0
  cargarEjecutores()
}

const buscarEnTabla = () => {
  paginaActual.value = 0
  cargarEjecutores()
}

// Buscar ejecutor por clave (usa sp_ejecutores_list con filtro)
const buscarEjecutor = async () => {
  if (!cveEjecutor.value || cveEjecutor.value <= 0) {
    showToast('warning', 'Error en el Numero de Ejecutor')
    return
  }

  showLoading('Buscando ejecutor...')
  try {
    // Usamos sp_ejecutores_list con el cve_eje como filtro
    const params = [
      { nombre: 'p_q', tipo: 'C', valor: String(cveEjecutor.value) },
      { nombre: 'p_vigencia', tipo: 'C', valor: '' },
      { nombre: 'p_offset', tipo: 'I', valor: 0 },
      { nombre: 'p_limit', tipo: 'I', valor: 100 }
    ]
    const data = await execute(OP_LIST, BASE_DB, params, 'guadalajara', null, SCHEMA)

    // Parsear respuesta
    let resultados = []
    if (Array.isArray(data)) {
      resultados = data
    } else if (data?.rows && Array.isArray(data.rows)) {
      resultados = data.rows
    } else if (data?.data && Array.isArray(data.data)) {
      resultados = data.data
    }

    // Buscar el ejecutor exacto por cve_eje (comparar como número)
    const arr = resultados.filter(e => Number(e.cve_eje) === Number(cveEjecutor.value))

    // Debug: ver datos encontrados
    console.log('Ejecutor encontrado:', arr.length > 0 ? arr[0] : 'No encontrado')

    showFormulario.value = true

    if (arr.length > 0) {
      // Ejecutor existe
      const ej = arr[0]
      ejecutorExiste.value = true

      // Guardar datos originales
      Object.assign(ejecutor, {
        cve_eje: ej.cve_eje,
        nombre: ej.nombre,
        ini_rfc: ej.ini_rfc,
        fec_rfc: ej.fec_rfc,
        hom_rfc: ej.hom_rfc,
        id_rec: ej.id_rec,
        oficio: ej.oficio,
        fecinic: ej.fecinic,
        fecterm: ej.fecterm,
        vigencia: ej.vigencia || 'A'
      })

      // Llenar formulario (trim para limpiar espacios)
      form.nombre = (ej.nombre || '').trim()
      form.ini_rfc = (ej.ini_rfc || '').trim()
      form.fec_rfc = ej.fec_rfc ? formatDateForInput(ej.fec_rfc) : ''
      form.hom_rfc = (ej.hom_rfc || '').trim()
      form.oficio = (ej.oficio || '').trim()
      form.fecinic = ej.fecinic ? formatDateForInput(ej.fecinic) : ''
      form.fecterm = ej.fecterm ? formatDateForInput(ej.fecterm) : ''

      // Debug: ver datos cargados en form
      console.log('Datos cargados en form:', { ...form })

      hideLoading()
      showToast('info', `Ejecutor ${cveEjecutor.value} encontrado - ${ej.vigencia === 'B' ? 'DADO DE BAJA' : 'ACTIVO'}`)
    } else {
      // Ejecutor nuevo
      ejecutorExiste.value = false
      Object.assign(ejecutor, {
        cve_eje: cveEjecutor.value,
        nombre: '',
        ini_rfc: '',
        fec_rfc: null,
        hom_rfc: '',
        id_rec: idRecActual.value,
        oficio: '',
        fecinic: null,
        fecterm: null,
        vigencia: 'A'
      })

      // Limpiar formulario
      form.nombre = ''
      form.ini_rfc = ''
      form.fec_rfc = ''
      form.hom_rfc = ''
      form.oficio = ''
      form.fecinic = ''
      form.fecterm = ''

      hideLoading()
      showToast('info', `Ejecutor ${cveEjecutor.value} no existe - Se creará nuevo registro`)
    }

    // Focus en el campo nombre
    await nextTick()
    inputNombre.value?.focus()

  } catch (error) {
    hideLoading()
    handleApiError(error)
  }
}

// Validar formulario (como en Pascal original)
const validarFormulario = () => {
  if (!form.nombre || form.nombre.trim().length === 0) {
    showToast('warning', 'Error: El nombre debe contener información')
    return false
  }
  if (!form.ini_rfc || form.ini_rfc.trim().length === 0) {
    showToast('warning', 'Error: Las Iniciales RFC deben contener información')
    return false
  }
  if (!form.fec_rfc) {
    showToast('warning', 'Error: La Fecha de Nac. debe contener información')
    return false
  }
  if (!form.hom_rfc || form.hom_rfc.trim().length === 0) {
    showToast('warning', 'Error: La Homo Clave debe contener información')
    return false
  }
  if (!form.oficio || form.oficio.trim().length === 0) {
    showToast('warning', 'Error: El Oficio debe contener información')
    return false
  }
  if (!form.fecinic) {
    showToast('warning', 'Error: La Fecha Inicio debe contener información')
    return false
  }
  if (!form.fecterm) {
    showToast('warning', 'Error: La Fecha Término debe contener información')
    return false
  }
  return true
}

// Guardar ejecutor (Alta o Modifica)
const guardarEjecutor = async () => {
  if (!validarFormulario()) return

  // Confirmación antes de guardar
  const accion = ejecutorExiste.value ? 'actualizar' : 'crear'
  const confirmResult = await Swal.fire({
    icon: 'question',
    title: `¿Confirmar ${accion} ejecutor?`,
    html: `
      <div style="text-align: left; padding: 0 20px;">
        <p style="margin-bottom: 10px;">Se ${ejecutorExiste.value ? 'actualizarán' : 'registrarán'} los siguientes datos:</p>
        <ul style="list-style: none; padding: 0;">
          <li style="margin: 5px 0;"><strong>Clave:</strong> ${cveEjecutor.value}</li>
          <li style="margin: 5px 0;"><strong>Nombre:</strong> ${form.nombre.toUpperCase()}</li>
          <li style="margin: 5px 0;"><strong>RFC:</strong> ${form.ini_rfc.toUpperCase()}-${form.fec_rfc}-${form.hom_rfc.toUpperCase()}</li>
          <li style="margin: 5px 0;"><strong>Oficio:</strong> ${form.oficio}</li>
        </ul>
      </div>
    `,
    showCancelButton: true,
    confirmButtonColor: '#198754',
    cancelButtonColor: '#6c757d',
    confirmButtonText: ejecutorExiste.value ? 'Sí, Guardar' : 'Sí, Crear',
    cancelButtonText: 'Cancelar'
  })

  if (!confirmResult.isConfirmed) return

  saving.value = true
  showLoading(ejecutorExiste.value ? 'Modificando ejecutor...' : 'Registrando ejecutor...')

  try {
    let result
    if (ejecutorExiste.value) {
      // Modificar (también reactiva si estaba de baja)
      const params = [
        { nombre: 'p_cve_eje', tipo: 'I', valor: cveEjecutor.value },
        { nombre: 'p_id_rec', tipo: 'I', valor: idRecActual.value },
        { nombre: 'p_ini_rfc', tipo: 'C', valor: form.ini_rfc.toUpperCase() },
        { nombre: 'p_fec_rfc', tipo: 'D', valor: form.fec_rfc },
        { nombre: 'p_hom_rfc', tipo: 'C', valor: form.hom_rfc.toUpperCase() },
        { nombre: 'p_nombre', tipo: 'C', valor: form.nombre.toUpperCase() },
        { nombre: 'p_oficio', tipo: 'C', valor: form.oficio },
        { nombre: 'p_fecinic', tipo: 'D', valor: form.fecinic },
        { nombre: 'p_fecterm', tipo: 'D', valor: form.fecterm }
      ]
      result = await execute(OP_UPDATE, BASE_DB, params, 'guadalajara', null, SCHEMA)
    } else {
      // Alta
      const params = [
        { nombre: 'p_cve_eje', tipo: 'I', valor: cveEjecutor.value },
        { nombre: 'p_ini_rfc', tipo: 'C', valor: form.ini_rfc.toUpperCase() },
        { nombre: 'p_fec_rfc', tipo: 'D', valor: form.fec_rfc },
        { nombre: 'p_hom_rfc', tipo: 'C', valor: form.hom_rfc.toUpperCase() },
        { nombre: 'p_nombre', tipo: 'C', valor: form.nombre.toUpperCase() },
        { nombre: 'p_id_rec', tipo: 'I', valor: idRecActual.value },
        { nombre: 'p_oficio', tipo: 'C', valor: form.oficio },
        { nombre: 'p_fecinic', tipo: 'D', valor: form.fecinic },
        { nombre: 'p_fecterm', tipo: 'D', valor: form.fecterm }
      ]
      result = await execute(OP_CREATE, BASE_DB, params, 'guadalajara', null, SCHEMA)
    }

    hideLoading()

    // Verificar resultado
    const arr = Array.isArray(result?.result) ? result.rows : Array.isArray(result) ? result : []
    const mensaje = arr.length > 0 ? arr[0].result : 'OK'

    if (mensaje === 'OK') {
      await Swal.fire({
        icon: 'success',
        title: ejecutorExiste.value ? '¡Ejecutor actualizado!' : '¡Ejecutor creado!',
        text: ejecutorExiste.value ? 'Los datos han sido actualizados correctamente' : 'El ejecutor ha sido registrado correctamente',
        confirmButtonColor: '#198754',
        timer: 2000
      })
      await cargarEjecutores()
      cerrarFormulario()
    } else {
      await Swal.fire({
        icon: 'error',
        title: 'Error',
        text: mensaje,
        confirmButtonColor: '#dc3545'
      })
    }

  } catch (error) {
    hideLoading()
    handleApiError(error)
  } finally {
    saving.value = false
  }
}

// Toggle vigencia (Baja/Reactiva)
const toggleVigencia = async () => {
  if (!ejecutorExiste.value) return

  const esBaja = ejecutorActivo.value // Si está activo, la acción será dar de baja

  // Confirmación antes de dar de baja/reactivar
  const confirmResult = await Swal.fire({
    icon: 'warning',
    title: esBaja ? '¿Dar de baja al ejecutor?' : '¿Reactivar ejecutor?',
    html: `
      <div style="text-align: left; padding: 0 20px;">
        <p style="margin-bottom: 10px;">${esBaja ? 'Se dará de baja al siguiente ejecutor:' : 'Se reactivará al siguiente ejecutor:'}</p>
        <ul style="list-style: none; padding: 0;">
          <li style="margin: 5px 0;"><strong>Clave:</strong> ${cveEjecutor.value}</li>
          <li style="margin: 5px 0;"><strong>Nombre:</strong> ${ejecutor.nombre}</li>
        </ul>
        ${esBaja ? '<p style="color: #dc3545; margin-top: 15px;"><strong>Esta acción desactivará al ejecutor.</strong></p>' : ''}
      </div>
    `,
    showCancelButton: true,
    confirmButtonColor: esBaja ? '#dc3545' : '#198754',
    cancelButtonColor: '#6c757d',
    confirmButtonText: esBaja ? 'Sí, Dar de Baja' : 'Sí, Reactivar',
    cancelButtonText: 'Cancelar'
  })

  if (!confirmResult.isConfirmed) return

  saving.value = true
  showLoading(esBaja ? 'Dando de baja...' : 'Reactivando...')

  try {
    const params = [
      { nombre: 'p_cve_eje', tipo: 'I', valor: cveEjecutor.value },
      { nombre: 'p_id_rec', tipo: 'I', valor: idRecActual.value }
    ]
    const result = await execute(OP_TOGGLE, BASE_DB, params, 'guadalajara', null, SCHEMA)

    hideLoading()

    // Debug: ver estructura de respuesta
    console.log('Respuesta toggleVigencia:', result)

    // Parsear respuesta - manejar diferentes estructuras
    let mensaje = ''
    if (Array.isArray(result?.result) && result.result.length > 0) {
      // Formato: {result: Array(1), count: 1}
      mensaje = result.result[0].result || result.result[0].sp_ejecutor_toggle_vigencia || ''
    } else if (Array.isArray(result?.result) && result.rows.length > 0) {
      mensaje = result.rows[0].result || result.rows[0].sp_ejecutor_toggle_vigencia || ''
    } else if (Array.isArray(result?.data) && result.data.length > 0) {
      mensaje = result.data[0].result || result.data[0].sp_ejecutor_toggle_vigencia || ''
    } else if (Array.isArray(result) && result.length > 0) {
      mensaje = result[0].result || result[0].sp_ejecutor_toggle_vigencia || ''
    } else if (typeof result === 'string') {
      mensaje = result
    }

    // Normalizar mensaje (trim y comparar sin importar mayúsculas)
    mensaje = (mensaje || '').toString().trim()

    if (mensaje.toLowerCase() === 'baja') {
      await Swal.fire({
        icon: 'success',
        title: '¡Ejecutor dado de baja!',
        text: 'El ejecutor ha sido desactivado correctamente',
        confirmButtonColor: '#198754',
        timer: 2000
      })
    } else if (mensaje.toLowerCase() === 'reactivado') {
      await Swal.fire({
        icon: 'success',
        title: '¡Ejecutor reactivado!',
        text: 'El ejecutor ha sido activado nuevamente',
        confirmButtonColor: '#198754',
        timer: 2000
      })
    } else {
      await Swal.fire({
        icon: 'error',
        title: 'Error',
        text: mensaje || 'Error al procesar',
        confirmButtonColor: '#dc3545'
      })
    }

    await cargarEjecutores()
    cerrarFormulario()

  } catch (error) {
    hideLoading()
    handleApiError(error)
  } finally {
    saving.value = false
  }
}

// Otro registro
const otroRegistro = () => {
  showFormulario.value = false
  ejecutorExiste.value = false
  cveEjecutor.value = null

  Object.assign(ejecutor, {
    cve_eje: null,
    nombre: '',
    ini_rfc: '',
    fec_rfc: null,
    hom_rfc: '',
    id_rec: null,
    oficio: '',
    fecinic: null,
    fecterm: null,
    vigencia: 'A'
  })

  Object.assign(form, {
    nombre: '',
    ini_rfc: '',
    fec_rfc: '',
    hom_rfc: '',
    oficio: '',
    fecinic: '',
    fecterm: ''
  })
}

// Cerrar formulario
const cerrarFormulario = () => {
  showFormulario.value = false
  otroRegistro()
}

// Seleccionar ejecutor de la tabla (usa datos directamente sin consultar)
const seleccionarEjecutor = (ej) => {
  console.log('Ejecutor seleccionado:', ej)

  cveEjecutor.value = ej.cve_eje
  ejecutorExiste.value = true

  // Guardar datos originales
  Object.assign(ejecutor, {
    cve_eje: ej.cve_eje,
    nombre: ej.nombre,
    ini_rfc: ej.ini_rfc,
    fec_rfc: ej.fec_rfc,
    hom_rfc: ej.hom_rfc,
    id_rec: ej.id_rec,
    oficio: ej.oficio,
    fecinic: ej.fecinic,
    fecterm: ej.fecterm,
    vigencia: ej.vigencia || 'A'
  })

  // Llenar formulario (trim para limpiar espacios)
  form.nombre = (ej.nombre || '').trim()
  form.ini_rfc = (ej.ini_rfc || '').trim()
  form.fec_rfc = ej.fec_rfc ? formatDateForInput(ej.fec_rfc) : ''
  form.hom_rfc = (ej.hom_rfc || '').trim()
  form.oficio = (ej.oficio || '').trim()
  form.fecinic = ej.fecinic ? formatDateForInput(ej.fecinic) : ''
  form.fecterm = ej.fecterm ? formatDateForInput(ej.fecterm) : ''

  // Mostrar modal
  showFormulario.value = true
}

// Cambiar recaudadora
const onRecaudadoraChange = () => {
  cargarEjecutores()
  otroRegistro()
}

// Toggle tabla
const toggleTabla = () => {
  showTabla.value = !showTabla.value
}

// Reload
const reload = async () => {
  showLoading('Actualizando lista de ejecutores...')
  try {
    await cargarEjecutores()
    showToast('success', 'Lista actualizada')
  } finally {
    hideLoading()
  }
}

// ========== HELPERS ==========
const formatDate = (dateStr) => {
  if (!dateStr) return '-'
  try {
    const date = new Date(dateStr)
    return new Intl.DateTimeFormat('es-MX').format(date)
  } catch {
    return dateStr
  }
}

const formatDateForInput = (dateStr) => {
  if (!dateStr) return ''
  try {
    const date = new Date(dateStr)
    return date.toISOString().split('T')[0]
  } catch {
    return ''
  }
}

const formatRFC = (ej) => {
  if (!ej.ini_rfc) return '-'
  const fecha = ej.fec_rfc ? formatDate(ej.fec_rfc) : ''
  const hom = ej.hom_rfc || ''
  return `${ej.ini_rfc}-${fecha}-${hom}`.replace(/--+/g, '-').replace(/-$/, '')
}

// ========== LIFECYCLE ==========
onMounted(async () => {
  // Obtener datos del usuario logueado
  // TODO: Obtener idRecUsuario del store/session
  idRecUsuario.value = 1
  idRecSeleccionado.value = idRecUsuario.value
  tienePermiso.value = true // TODO: Verificar permisos reales

  await cargarRecaudadoras()
  await cargarEjecutores()
})

// Documentacion y Ayuda
const showDocumentation = ref(false)
const openDocumentation = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false
const showTechDocs = ref(false)
const mostrarDocumentacion = () => showTechDocs.value = true
const closeTechDocs = () => showTechDocs.value = false
</script>

<!-- Sin estilos scoped - Todo desde municipal-theme.css -->
