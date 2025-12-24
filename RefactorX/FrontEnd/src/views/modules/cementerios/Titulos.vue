<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="file-contract" />
      </div>
      <div class="module-view-info">
        <h1>Gestión de Títulos de Fosas</h1>
        <p>Cementerios - Impresión y actualización de títulos de propiedad</p>
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
      </div>
    </div>

    <div class="module-view-content">
      <!-- Búsqueda de Título por Folio -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="search" />
            Buscar Título por Folio
          </h5>
        </div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label required">Fecha del Título</label>
              <input
                type="date"
                class="municipal-form-control"
                v-model="busqueda.fecha"
                @keyup.enter="buscarTitulo"
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label required">Folio (Cuenta)</label>
              <input
                type="number"
                class="municipal-form-control"
                v-model="busqueda.folio"
                @keyup.enter="buscarTitulo"
                placeholder="Número de folio..."
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label required">Operación</label>
              <input
                type="number"
                class="municipal-form-control"
                v-model="busqueda.operacion"
                @keyup.enter="buscarTitulo"
                placeholder="Número de operación..."
              />
            </div>
          </div>
          <div class="button-group">
            <button
              class="btn-municipal-primary"
              @click="buscarTitulo"
              :disabled="!busqueda.fecha || !busqueda.folio || !busqueda.operacion"
            >
              <font-awesome-icon icon="search" />
              Buscar Título
            </button>
            <button
              class="btn-municipal-secondary"
              @click="limpiarBusqueda"
            >
              <font-awesome-icon icon="times" />
              Limpiar
            </button>
          </div>
        </div>
      </div>

      <!-- Datos del Título Encontrado -->
      <div class="municipal-card" v-if="tituloActual">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="file-contract" />
            Datos del Título #{{ tituloActual.titulo }}
          </h5>
        </div>
        <div class="municipal-card-body">
          <!-- Datos de la Fosa -->
          <h6 class="section-title">Datos de la Fosa</h6>
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Cementerio</label>
              <input
                type="text"
                class="municipal-form-control"
                :value="tituloActual.cementerio"
                readonly
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Ubicación</label>
              <input
                type="text"
                class="municipal-form-control"
                :value="ubicacionFosa"
                readonly
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Metros</label>
              <input
                type="text"
                class="municipal-form-control"
                :value="tituloActual.metros || 'N/A'"
                readonly
              />
            </div>
          </div>

          <!-- Datos del Propietario -->
          <h6 class="section-title">Datos del Propietario</h6>
          <div class="form-row">
            <div class="form-group full-width">
              <label class="municipal-form-label">Nombre</label>
              <input
                type="text"
                class="municipal-form-control"
                :value="tituloActual.nombre"
                readonly
              />
            </div>
          </div>
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Domicilio</label>
              <input
                type="text"
                class="municipal-form-control"
                :value="tituloActual.domicilio"
                readonly
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Colonia</label>
              <input
                type="text"
                class="municipal-form-control"
                :value="tituloActual.colonia"
                readonly
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Teléfono</label>
              <input
                type="text"
                class="municipal-form-control"
                :value="tituloActual.telefono || 'N/A'"
                readonly
              />
            </div>
          </div>

          <!-- Datos del Título (Editables) -->
          <h6 class="section-title">Datos del Título (Beneficiario)</h6>
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label required">Libro</label>
              <input
                type="number"
                class="municipal-form-control"
                v-model="formData.libro"
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label required">Año</label>
              <input
                type="number"
                class="municipal-form-control"
                v-model="formData.axo"
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label required">Folio</label>
              <input
                type="number"
                class="municipal-form-control"
                v-model="formData.folio_titulo"
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Partida</label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="formData.partida"
                maxlength="20"
              />
            </div>
          </div>

          <div class="form-row">
            <div class="form-group full-width">
              <label class="municipal-form-label required">Nombre Beneficiario</label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="formData.nombre_ben"
                maxlength="100"
              />
            </div>
          </div>

          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label required">Domicilio Beneficiario</label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="formData.dom_ben"
                maxlength="100"
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label required">Colonia Beneficiario</label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="formData.col_ben"
                maxlength="60"
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label required">Teléfono Beneficiario</label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="formData.tel_ben"
                maxlength="20"
              />
            </div>
          </div>

          <div class="button-group">
            <button
              class="btn-municipal-primary"
              @click="guardarTitulo"
              :disabled="guardando || !validarFormulario()"
            >
              <span v-if="guardando" class="spinner-border spinner-border-sm me-2"></span>
              {{ guardando ? 'Guardando...' : 'Guardar Datos del Título' }}
            </button>
            <button
              class="btn-municipal-secondary"
              @click="prepararImpresion"
              :disabled="!tituloGuardado"
            >
              <font-awesome-icon icon="print" />
              Preparar Impresión
            </button>
          </div>
        </div>
      </div>

      <!-- Listado de Títulos -->
      <div class="municipal-card">
        <div class="municipal-card-header header-with-badge">
          <h5>
            <font-awesome-icon icon="list" />
            Títulos Registrados
          </h5>
          <div class="header-right">
            <span class="badge-purple" v-if="titulos.length > 0">
              {{ titulos.length }} registros
            </span>
          </div>
        </div>

        <div class="municipal-card-body">
          <!-- Empty State - Sin búsqueda -->
          <div v-if="titulos.length === 0 && !hasSearched" class="empty-state">
            <div class="empty-state-icon">
              <font-awesome-icon icon="file-contract" size="3x" />
            </div>
            <h4>Gestión de Títulos de Fosas</h4>
            <p>Utilice el formulario de búsqueda para localizar títulos por folio y operación</p>
          </div>

          <!-- Empty State - Sin resultados -->
          <div v-else-if="titulos.length === 0 && hasSearched" class="empty-state">
            <div class="empty-state-icon">
              <font-awesome-icon icon="inbox" size="3x" />
            </div>
            <h4>Sin resultados</h4>
            <p>No se encontraron títulos con los criterios especificados</p>
          </div>

          <!-- Tabla con resultados -->
          <div v-else>
            <div class="table-responsive">
              <table class="municipal-table">
                <thead class="municipal-table-header">
                  <tr>
                    <th>Folio</th>
                    <th>Título</th>
                    <th>Fecha</th>
                    <th>Cementerio</th>
                    <th>Propietario</th>
                    <th>Ubicación</th>
                    <th>Beneficiario</th>
                    <th>Libro/Año/Folio</th>
                    <th>Acciones</th>
                  </tr>
                </thead>
                <tbody>
                  <tr
                    v-for="titulo in paginatedTitulos"
                    :key="`${titulo.control_rcm}-${titulo.titulo}`"
                    @click="selectedRow = titulo"
                    :class="{ 'table-row-selected': selectedRow === titulo }"
                    class="row-hover"
                  >
                    <td><strong class="text-primary">{{ titulo.control_rcm }}</strong></td>
                    <td>{{ titulo.titulo }}</td>
                    <td>
                      <small class="text-muted">
                        {{ formatDate(titulo.fecha) }}
                      </small>
                    </td>
                    <td>{{ titulo.cementerio }}</td>
                    <td>{{ titulo.nombre }}</td>
                    <td>
                      <small>C:{{ titulo.clase_alfa }} S:{{ titulo.seccion_alfa }} L:{{ titulo.linea_alfa }} F:{{ titulo.fosa_alfa }}</small>
                    </td>
                    <td>{{ titulo.nombre_ben || '-' }}</td>
                    <td>
                      <small v-if="titulo.libro">{{ titulo.libro }}/{{ titulo.axo }}/{{ titulo.folio_titulo }}</small>
                      <small v-else>-</small>
                    </td>
                    <td>
                      <div class="action-buttons">
                        <button
                          class="btn-municipal-primary btn-sm"
                          @click.stop="cargarTitulo(titulo)"
                          title="Editar"
                        >
                          <font-awesome-icon icon="edit" />
                        </button>
                      </div>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>

            <!-- Paginación -->
            <div v-if="titulos.length > 0" class="pagination-controls">
              <div class="pagination-info">
                <span class="text-muted">
                  Mostrando {{ ((currentPage - 1) * itemsPerPage) + 1 }}
                  a {{ Math.min(currentPage * itemsPerPage, totalRecords) }}
                  de {{ formatNumber(totalRecords) }} registros
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
                  <option value="5">5</option>
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

      <!-- Modal de Ayuda -->
      <DocumentationModal
        :show="showDocModal"
        :componentName="'Titulos'"
        :moduleName="'cementerios'"
        :docType="docType"
        :title="'Gestión de Títulos de Fosas'"
        @close="showDocModal = false"
      />
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue'
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { useApi } from '@/composables/useApi'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import Swal from 'sweetalert2'

const { execute } = useApi()
const { showLoading, hideLoading } = useGlobalLoading()

const {
  toast,
  showToast,
  hideToast,
  getToastIcon,
  handleApiError
} = useLicenciasErrorHandler()

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

// Estado
const selectedRow = ref(null)
const hasSearched = ref(false)
const guardando = ref(false)
const titulos = ref([])
const tituloActual = ref(null)
const tituloGuardado = ref(false)

// Búsqueda
const busqueda = ref({
  folio: null,
  operacion: null,
  fecha: new Date().toISOString().split('T')[0] // Fecha actual en formato YYYY-MM-DD
})

// Paginación
const currentPage = ref(1)
const itemsPerPage = ref(10)

// Formulario
const formData = ref({
  libro: null,
  axo: null,
  folio_titulo: null,
  nombre_ben: '',
  dom_ben: '',
  col_ben: '',
  tel_ben: '',
  partida: ''
})

// Computed
const totalRecords = computed(() => titulos.value.length)
const totalPages = computed(() => Math.ceil(totalRecords.value / itemsPerPage.value))

const paginatedTitulos = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage.value
  const end = start + itemsPerPage.value
  return titulos.value.slice(start, end)
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

const ubicacionFosa = computed(() => {
  if (!tituloActual.value) return ''
  const { clase_alfa, seccion_alfa, linea_alfa, fosa_alfa } = tituloActual.value
  return `Clase: ${clase_alfa}, Sección: ${seccion_alfa}, Línea: ${linea_alfa}, Fosa: ${fosa_alfa}`
})

// Métodos
const cargarTitulos = async () => {
  showLoading('Cargando títulos', 'Obteniendo listado de títulos registrados...')
  hasSearched.value = true
  selectedRow.value = null
  try {
    const response = await execute(
      'sp_titulos_actualizar_numero',
      'cementerio',
      [ { nombre: 'p_recaudadora', valor: filtros.recaudadora, tipo: 'integer' },
        {   nombre: 'p_recaudadora', valor: filtros.recaudadora, tipo: 'integer' },
        { nombre: 'p_recaudadora', valor: filtros.recaudadora, tipo: 'integer' },
        { nombre: 'p_recaudadora', valor: filtros.recaudadora, tipo: 'integer' },

        // p_page: currentPage.value,
        // p_page_size: itemsPerPage.value,
        // p_search: null,
        // p_cementerio: null,
        // p_order_by: 'fecha'
      ] ,
      '',
      null,
      'public'
    )

    if (response && response.result && response.result.length > 0) {
      titulos.value = response.result
    } else {
      titulos.value = []
    }
  } catch (error) {
    handleApiError(error, 'Error al cargar títulos')
    titulos.value = []
  } finally {
    hideLoading()
  }
}

const buscarTitulo = async () => {
  if (!busqueda.value.folio || !busqueda.value.operacion) {
    showToast('warning', 'Debe ingresar folio y operación')
    return
  }

  showLoading('Buscando título', 'Consultando información del título...')
  hasSearched.value = true
  selectedRow.value = null
  try {
    const response = await execute(
      'sp_titulos_buscar_por_folio_operacion',
      'cementerio',
      [
         { nombre: 'p_fecha', valor: busqueda.value.fecha, tipo: 'date' },
         { nombre: 'p_folio', valor: busqueda.value.folio, tipo: 'integer' },
         { nombre: 'p_operacion', valor: busqueda.value.operacion, tipo: 'integer' },

    ],
      '',
      null,
      'public'
    )

    if (response && response.result && response.result.length > 0) {
      const result = response.result[0]
      if (result.resultado === 'S') {
        tituloActual.value = result
        tituloGuardado.value = false

        // Cargar datos existentes del título extra
        formData.value = {
          libro: result.libro || null,
          axo: result.axo || null,
          folio_titulo: result.folio_titulo || null,
          nombre_ben: result.nombre_ben || '',
          dom_ben: result.dom_ben || '',
          col_ben: result.col_ben || '',
          tel_ben: result.tel_ben || '',
          partida: result.partida || ''
        }

        showToast('success', result.mensaje)
      } else {
        showToast('error', result.mensaje)
        tituloActual.value = null
      }
    }
  } catch (error) {
    handleApiError(error, 'Error al buscar título')
    tituloActual.value = null
  } finally {
    hideLoading()
  }
}

const validarFormulario = () => {
  return formData.value.libro &&
         formData.value.axo &&
         formData.value.folio_titulo &&
         formData.value.nombre_ben &&
         formData.value.dom_ben &&
         formData.value.col_ben &&
         formData.value.tel_ben
}

const guardarTitulo = async () => {
  if (!validarFormulario()) {
    showToast('warning', 'Por favor complete todos los campos requeridos')
    return
  }

  guardando.value = true
  try {
    const response = await execute(
      'sp_titulos_actualizar_datos_extra',
      'cementerio',
      {
        p_control_rcm: tituloActual.value.control_rcm,
        p_titulo: tituloActual.value.titulo,
        p_fecha_imp: new Date().toISOString().split('T')[0],
        p_libro: formData.value.libro,
        p_axo: formData.value.axo,
        p_folio: formData.value.folio_titulo,
        p_nombre_ben: formData.value.nombre_ben,
        p_dom_ben: formData.value.dom_ben,
        p_col_ben: formData.value.col_ben,
        p_tel_ben: formData.value.tel_ben,
        p_partida: formData.value.partida || ''
      },
      '',
      null,
      'public'
    )

    if (response && response[0]) {
      const result = response.result[0]
      if (result.resultado === 'S') {
        showToast('success', result.mensaje)
        tituloGuardado.value = true
        cargarTitulos() // Recargar listado
      } else {
        showToast('error', result.mensaje)
      }
    }
  } catch (error) {
    showToast('error', 'Error al guardar datos del título: ' + error.message)
  } finally {
    guardando.value = false
  }
}

const prepararImpresion = () => {
  Swal.fire({
    title: 'Preparar Impresión',
    html: `¿Desea preparar la impresión del título?<br><br>
           <strong>Folio:</strong> ${tituloActual.value.control_rcm}<br>
           <strong>Título:</strong> ${tituloActual.value.titulo}<br>
           <strong>Beneficiario:</strong> ${formData.value.nombre_ben}<br>
           <strong>Libro/Año/Folio:</strong> ${formData.value.libro}/${formData.value.axo}/${formData.value.folio_titulo}`,
    icon: 'info',
    showCancelButton: true,
    confirmButtonText: 'Preparar',
    cancelButtonText: 'Cancelar',
    confirmButtonColor: '#ea8215',
    cancelButtonColor: '#6c757d'
  }).then((result) => {
    if (result.isConfirmed) {
      showToast('info', 'La funcionalidad de impresión se implementará próximamente')
    }
  })
}

const cargarTitulo = (titulo) => {
  busqueda.value = {
    folio: titulo.control_rcm,
    operacion: titulo.operacion
  }
  buscarTitulo()
}

const limpiarBusqueda = () => {
  busqueda.value = {
    folio: null,
    operacion: null,
    fecha: new Date().toISOString().split('T')[0] // Restablecer a fecha actual
  }
  tituloActual.value = null
  tituloGuardado.value = false
  hasSearched.value = false
  currentPage.value = 1
  selectedRow.value = null
  formData.value = {
    libro: null,
    axo: null,
    folio_titulo: null,
    nombre_ben: '',
    dom_ben: '',
    col_ben: '',
    tel_ben: '',
    partida: ''
  }
}

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

const formatNumber = (number) => {
  return new Intl.NumberFormat('es-MX').format(number)
}

const formatDate = (date) => {
  if (!date) return 'N/A'
  return new Date(date).toLocaleDateString('es-MX')
}

// Inicializar
onMounted(() => {
  cargarTitulos()
})
</script>
