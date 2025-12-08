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
    
      <button
        type="button"
        class="btn-help-icon"
        @click="mostrarAyuda = true"
        title="Ayuda"
      >
        <font-awesome-icon icon="question-circle" />
      </button>
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
              :disabled="loading || !busqueda.folio || !busqueda.operacion"
            >
              <font-awesome-icon icon="search" />
              Buscar Título
            </button>
            <button
              class="btn-municipal-secondary"
              @click="limpiarBusqueda"
              :disabled="loading"
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
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="list" />
            Títulos Registrados
            <span class="badge-info" v-if="totalRecords > 0">{{ totalRecords }} registros</span>
          </h5>
          <div v-if="loading" class="spinner-border" role="status">
            <span class="visually-hidden">Cargando...</span>
          </div>
        </div>

        <div class="municipal-card-body table-container" v-if="!loading">
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
                <tr v-for="titulo in titulos" :key="`${titulo.control_rcm}-${titulo.titulo}`" class="row-hover">
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
                        @click="cargarTitulo(titulo)"
                        title="Editar"
                      >
                        <font-awesome-icon icon="edit" />
                      </button>
                    </div>
                  </td>
                </tr>
                <tr v-if="titulos.length === 0">
                  <td colspan="9" class="text-center text-muted">
                    No se encontraron títulos
                  </td>
                </tr>
              </tbody>
            </table>
          </div>

          <!-- Paginación -->
          <div class="pagination-container" v-if="totalPages > 1">
            <div class="pagination-info">
              Página {{ currentPage }} de {{ totalPages }}
            </div>
            <div class="pagination-controls">
              <button
                class="pagination-button"
                @click="cambiarPagina(currentPage - 1)"
                :disabled="currentPage === 1"
              >
                <font-awesome-icon icon="chevron-left" />
                Anterior
              </button>
              <button
                class="pagination-button"
                @click="cambiarPagina(currentPage + 1)"
                :disabled="currentPage === totalPages"
              >
                Siguiente
                <font-awesome-icon icon="chevron-right" />
              </button>
            </div>
          </div>
        </div>

        <div v-if="loading" class="text-center py-5">
          <div class="spinner-border text-primary" role="status">
            <span class="visually-hidden">Cargando...</span>
          </div>
          <p class="mt-3">Cargando títulos...</p>
        </div>
      </div>
    </div>

    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="mostrarAyuda"
      @close="mostrarAyuda = false"
      title="Gestión de Títulos de Fosas"
    >
      <h6>Descripción</h6>
      <p>Módulo para la gestión e impresión de títulos de propiedad de fosas en cementerios municipales.</p>

      <h6>Funcionalidades</h6>
      <ul>
        <li>Búsqueda de títulos por folio y operación</li>
        <li>Actualización de datos del beneficiario</li>
        <li>Registro de libro, año y folio del título impreso</li>
        <li>Listado de todos los títulos registrados</li>
        <li>Preparación para impresión de títulos</li>
      </ul>

      <h6>Instrucciones</h6>
      <ol>
        <li>Ingrese el folio (cuenta) y número de operación del pago</li>
        <li>Haga clic en "Buscar Título" para cargar los datos</li>
        <li>Complete los datos del beneficiario y título (libro, año, folio)</li>
        <li>Guarde los datos antes de preparar la impresión</li>
        <li>Use "Preparar Impresión" para generar el título</li>
      </ol>
    </DocumentationModal>
    <!-- Modal de Documentacion Tecnica -->
    <TechnicalDocsModal
      :show="showTechDocs"
      :componentName="'Titulos'"
      :moduleName="'cementerios'"
      @close="closeTechDocs"
    />

  </div>
</template>

<script setup>
import TechnicalDocsModal from '@/components/common/TechnicalDocsModal.vue'
import { ref, onMounted, computed } from 'vue'
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { useApi } from '@/composables/useApi'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import { useToast } from '@/composables/useToast'
import Swal from 'sweetalert2'

const { execute } = useApi()
const { showLoading, hideLoading } = useGlobalLoading()
const { showToast } = useToast()

// Estado
const loading = ref(false)
const guardando = ref(false)
const titulos = ref([])
const tituloActual = ref(null)
const tituloGuardado = ref(false)
const mostrarAyuda = ref(false)

// Búsqueda
const busqueda = ref({
  folio: null,
  operacion: null
})

// Paginación
const currentPage = ref(1)
const pageSize = ref(10)
const totalRecords = ref(0)

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
const totalPages = computed(() => Math.ceil(totalRecords.value / pageSize.value))

const ubicacionFosa = computed(() => {
  if (!tituloActual.value) return ''
  const { clase_alfa, seccion_alfa, linea_alfa, fosa_alfa } = tituloActual.value
  return `Clase: ${clase_alfa}, Sección: ${seccion_alfa}, Línea: ${linea_alfa}, Fosa: ${fosa_alfa}`
})

// Métodos
const cargarTitulos = async () => {
  loading.value = true
  try {
    const response = await execute(
      'sp_cem_listar_titulos',
      'cementerios',
      {
        p_page: currentPage.value,
        p_page_size: pageSize.value,
        p_search: null,
        p_cementerio: null,
        p_order_by: 'fecha'
      },
      '',
      null,
      'comun'
    )

    if (response && response.result && response.result.length > 0) {
      titulos.value = response.result
      totalRecords.value = response.result[0].total_records || response.length
    } else {
      titulos.value = []
      totalRecords.value = 0
    }
  } catch (error) {
    showToast('Error al cargar títulos: ' + error.message, 'error')
    titulos.value = []
  } finally {
    loading.value = false
  }
}

const buscarTitulo = async () => {
  if (!busqueda.value.folio || !busqueda.value.operacion) {
    showToast('Debe ingresar folio y operación', 'warning')
    return
  }

  loading.value = true
  try {
    const response = await execute(
      'sp_cem_buscar_titulo',
      'cementerios',
      {
        p_folio: busqueda.value.folio,
        p_operacion: busqueda.value.operacion
      },
      '',
      null,
      'comun'
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

        showToast(result.mensaje, 'success')
      } else {
        showToast(result.mensaje, 'error')
        tituloActual.value = null
      }
    }
  } catch (error) {
    showToast('Error al buscar título: ' + error.message, 'error')
    tituloActual.value = null
  } finally {
    loading.value = false
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
    showToast('Por favor complete todos los campos requeridos', 'warning')
    return
  }

  guardando.value = true
  try {
    const response = await execute(
      'sp_cem_actualizar_titulo_extra',
      'cementerios',
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
      'comun'
    )

    if (response && response[0]) {
      const result = response.result[0]
      if (result.resultado === 'S') {
        showToast(result.mensaje, 'success')
        tituloGuardado.value = true
        cargarTitulos() // Recargar listado
      } else {
        showToast(result.mensaje, 'error')
      }
    }
  } catch (error) {
    showToast('Error al guardar datos del título: ' + error.message, 'error')
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
    cancelButtonText: 'Cancelar'
  }).then((result) => {
    if (result.isConfirmed) {
      showToast('La funcionalidad de impresión se implementará próximamente', 'info')
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
    operacion: null
  }
  tituloActual.value = null
  tituloGuardado.value = false
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

const cambiarPagina = (page) => {
  if (page >= 1 && page <= totalPages.value) {
    currentPage.value = page
    cargarTitulos()
  }
}

const formatDate = (date) => {
  if (!date) return 'N/A'
  return new Date(date).toLocaleDateString('es-MX')
}

// Inicializar
onMounted(() => {
  cargarTitulos()
})

// Documentacion y Ayuda
const showDocumentation = ref(false)
const openDocumentation = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false
const showTechDocs = ref(false)
const mostrarDocumentacion = () => showTechDocs.value = true
const closeTechDocs = () => showTechDocs.value = false

</script>
