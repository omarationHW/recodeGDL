<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header" style="position: relative;">
      <div class="module-view-icon">
        <font-awesome-icon icon="tags" />
      </div>
      <div class="module-view-info">
        <h1>Catálogo de Giros</h1>
        <p>Padrón de Licencias - Gestión del Catálogo de Giros Comerciales e Industriales</p></div>
      <button
        type="button"
        class="btn-help-icon"
        @click="openDocumentation"
        title="Ayuda"
      >
        <font-awesome-icon icon="question-circle" />
      </button>
    </div>

    <div class="module-view-content">
      <!-- Filtros de búsqueda -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5 class="municipal-card-title">
            <font-awesome-icon icon="filter" />
            Filtros de Búsqueda
          </h5>
        </div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group col-md-4">
              <label class="municipal-form-label">
                <font-awesome-icon icon="barcode" /> Código:
              </label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="filters.codigo"
                placeholder="Código del giro"
                @keyup.enter="buscar"
              />
            </div>

            <div class="form-group col-md-4">
              <label class="municipal-form-label">
                <font-awesome-icon icon="file-alt" /> Descripción:
              </label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="filters.descripcion"
                placeholder="Descripción del giro"
                @keyup.enter="buscar"
              />
            </div>

            <div class="form-group col-md-4">
              <label class="municipal-form-label">
                <font-awesome-icon icon="layer-group" /> Clasificación:
              </label>
              <select class="municipal-form-control" v-model="filters.clasificacion">
                <option value="">Todas</option>
                <option value="A">A - Clase A</option>
                <option value="B">B - Clase B</option>
                <option value="C">C - Clase C</option>
                <option value="D">D - Clase D</option>
              </select>
            </div>
          </div>

          <div class="form-row">
            <div class="form-group col-md-4">
              <label class="municipal-form-label">
                <font-awesome-icon icon="tag" /> Tipo:
              </label>
              <select class="municipal-form-control" v-model="filters.tipo">
                <option value="">Todos</option>
                <option value="L">L - Licencia</option>
                <option value="A">A - Anuncio</option>
              </select>
            </div>

            <div class="form-group col-md-4">
              <label class="municipal-form-label">
                <font-awesome-icon icon="check-circle" /> Vigencia:
              </label>
              <select class="municipal-form-control" v-model="filters.vigente">
                <option value="">Todos</option>
                <option value="V">Vigentes</option>
                <option value="C">Cancelados</option>
              </select>
            </div>

            <div class="form-group col-md-4">
              <label class="municipal-form-label">&nbsp;</label>
              <div class="btn-group-actions">
                <button @click="buscar" class="btn-municipal-primary">
                  <font-awesome-icon icon="search" /> Buscar
                </button>
                <button @click="limpiarFiltros" class="btn-municipal-secondary">
                  <font-awesome-icon icon="eraser" /> Limpiar
                </button>
                <button @click="abrirModalNuevo" class="btn-municipal-success">
                  <font-awesome-icon icon="plus" /> Nuevo
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Tabla de resultados -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5 class="municipal-card-title">
            <font-awesome-icon icon="list" />
            Listado de Giros
            <span class="badge badge-primary ms-2" v-if="totalRegistros">
              {{ totalRegistros.toLocaleString() }} registros
            </span>
          </h5>
        </div>
        <div class="municipal-card-body p-0">
          <div class="table-responsive">
            <table class="table table-hover mb-0">
              <thead>
                <tr>
                  <th>Código</th>
                  <th>Descripción</th>
                  <th>Clasificación</th>
                  <th>Tipo</th>
                  <th>Reglamentada</th>
                  <th>Vigente</th>
                  <th width="150">Acciones</th>
                </tr>
              </thead>
              <tbody>
                <tr v-if="loading">
                  <td colspan="7" class="text-center py-4">
                    <div class="spinner-border text-primary" role="status">
                      <span class="visually-hidden">Cargando...</span>
                    </div>
                  </td>
                </tr>
                <tr v-else-if="giros.length === 0">
                  <td colspan="7" class="text-center py-4 text-muted">
                    <font-awesome-icon icon="inbox" size="2x" class="mb-2" />
                    <p class="mb-0">No se encontraron giros con los filtros seleccionados</p>
                  </td>
                </tr>
                <tr v-else v-for="giro in giros" :key="giro.id_giro">
                  <td>
                    <span class="badge bg-secondary">{{ giro.cod_giro || 'S/N' }}</span>
                  </td>
                  <td class="text-truncate" style="max-width: 300px">{{ giro.descripcion }}</td>
                  <td>
                    <span class="badge" :class="{
                      'badge-success': giro.clasificacion === 'A',
                      'badge-info': giro.clasificacion === 'B',
                      'badge-warning': giro.clasificacion === 'C',
                      'badge-danger': giro.clasificacion === 'D'
                    }">
                      {{ giro.clasificacion || 'N/A' }}
                    </span>
                  </td>
                  <td>
                    <span class="badge bg-secondary">
                      {{ giro.tipo === 'L' ? 'Licencia' : giro.tipo === 'A' ? 'Anuncio' : 'N/A' }}
                    </span>
                  </td>
                  <td class="text-center">
                    <span class="badge" :class="giro.reglamentada === 'S' ? 'badge-danger' : 'bg-secondary'">
                      {{ giro.reglamentada === 'S' ? 'Sí' : 'No' }}
                    </span>
                  </td>
                  <td>
                    <span class="badge" :class="giro.vigente === 'V' ? 'badge-success' : 'bg-secondary'">
                      {{ giro.vigente === 'V' ? 'Vigente' : 'Cancelado' }}
                    </span>
                  </td>
                  <td>
                    <div class="btn-group">
                      <button @click="verDetalle(giro)" class="btn-action" title="Ver detalle">
                        <font-awesome-icon icon="eye" />
                      </button>
                      <button @click="editarGiro(giro)" class="btn-action" title="Editar">
                        <font-awesome-icon icon="edit" />
                      </button>
                      <button
                        v-if="giro.vigente === 'V'"
                        @click="cambiarVigencia(giro, 'C')"
                        class="btn-action btn-danger"
                        title="Cancelar"
                      >
                        <font-awesome-icon icon="ban" />
                      </button>
                      <button
                        v-else
                        @click="cambiarVigencia(giro, 'V')"
                        class="btn-action btn-success"
                        title="Reactivar"
                      >
                        <font-awesome-icon icon="check" />
                      </button>
                    </div>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>

          <!-- Paginación -->
          <div class="pagination-container" v-if="totalRegistros > 0 && !loading">
            <div class="pagination-info">
              <font-awesome-icon icon="info-circle" />
              Mostrando {{ ((paginaActual - 1) * registrosPorPagina) + 1 }}
              a {{ Math.min(paginaActual * registrosPorPagina, totalRegistros) }}
              de {{ totalRegistros }} registros
            </div>

            <div class="pagination-controls">
              <div class="page-size-selector">
                <label>Mostrar:</label>
                <select v-model="registrosPorPagina" @change="cambiarTamanioPagina">
                  <option :value="10">10</option>
                  <option :value="25">25</option>
                  <option :value="50">50</option>
                  <option :value="100">100</option>
                </select>
              </div>

              <div class="pagination-nav">
                <button
                  class="pagination-button"
                  @click="cambiarPagina(paginaActual - 1)"
                  :disabled="paginaActual === 1"
                >
                  <font-awesome-icon icon="chevron-left" />
                </button>

                <button
                  v-for="page in visiblePages"
                  :key="page"
                  class="pagination-button"
                  :class="{ active: page === paginaActual }"
                  @click="cambiarPagina(page)"
                >
                  {{ page }}
                </button>

                <button
                  class="pagination-button"
                  @click="cambiarPagina(paginaActual + 1)"
                  :disabled="paginaActual === totalPaginas"
                >
                  <font-awesome-icon icon="chevron-right" />
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Loading overlay -->
    <div v-if="loading" class="loading-overlay">
      <div class="loading-spinner">
        <div class="spinner"></div>
        <p>Cargando giros...</p>
      </div>
    </div>

    <!-- Modal para detalle/edición -->
    <Modal
      :show="mostrarModal"
      :title="modalTitle"
      size="lg"
      @close="cerrarModal"
    >
      <template #default>
        <div class="user-details">
          <div class="form-row">
            <div class="form-group col-md-6">
              <label class="municipal-form-label">
                <font-awesome-icon icon="barcode" /> Código del Giro *
              </label>
              <input
                type="number"
                class="municipal-form-control"
                v-model="giroForm.cod_giro"
                :readonly="modoEdicion === 'ver'"
                placeholder="Código numérico"
              />
            </div>

            <div class="form-group col-md-6">
              <label class="municipal-form-label">
                <font-awesome-icon icon="hashtag" /> Código de Anuncio
              </label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="giroForm.cod_anun"
                :readonly="modoEdicion === 'ver'"
                placeholder="Opcional (máx. 5 caracteres)"
                maxlength="5"
              />
            </div>
          </div>

          <div class="form-row">
            <div class="form-group col-md-12">
              <label class="municipal-form-label">
                <font-awesome-icon icon="file-alt" /> Descripción *
              </label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="giroForm.descripcion"
                :readonly="modoEdicion === 'ver'"
                placeholder="Descripción del giro"
                maxlength="96"
              />
            </div>
          </div>

          <div class="form-row">
            <div class="form-group col-md-12">
              <label class="municipal-form-label">
                <font-awesome-icon icon="info-circle" /> Características
              </label>
              <textarea
                class="municipal-form-control"
                v-model="giroForm.caracteristicas"
                :readonly="modoEdicion === 'ver'"
                placeholder="Características y observaciones del giro"
                rows="3"
                maxlength="130"
              ></textarea>
            </div>
          </div>

          <div class="form-row">
            <div class="form-group col-md-3">
              <label class="municipal-form-label">
                <font-awesome-icon icon="layer-group" /> Clasificación *
              </label>
              <select class="municipal-form-control" v-model="giroForm.clasificacion" :disabled="modoEdicion === 'ver'">
                <option value="A">A - Clase A</option>
                <option value="B">B - Clase B</option>
                <option value="C">C - Clase C</option>
                <option value="D">D - Clase D</option>
              </select>
            </div>

            <div class="form-group col-md-3">
              <label class="municipal-form-label">
                <font-awesome-icon icon="tag" /> Tipo *
              </label>
              <select class="municipal-form-control" v-model="giroForm.tipo" :disabled="modoEdicion === 'ver'">
                <option value="L">L - Licencia</option>
                <option value="A">A - Anuncio</option>
              </select>
            </div>

            <div class="form-group col-md-3">
              <label class="municipal-form-label">
                <font-awesome-icon icon="gavel" /> Reglamentada *
              </label>
              <select class="municipal-form-control" v-model="giroForm.reglamentada" :disabled="modoEdicion === 'ver'">
                <option value="N">No</option>
                <option value="S">Sí</option>
              </select>
            </div>

            <div class="form-group col-md-3">
              <label class="municipal-form-label">
                <font-awesome-icon icon="check-circle" /> Vigente *
              </label>
              <select class="municipal-form-control" v-model="giroForm.vigente" :disabled="modoEdicion === 'ver'">
                <option value="V">Vigente</option>
                <option value="C">Cancelado</option>
              </select>
            </div>
          </div>

          <!-- Información adicional (solo en modo ver) -->
          <div v-if="modoEdicion === 'ver' && giroForm.id_giro" class="detail-section mt-3">
            <h6 class="section-title">
              <font-awesome-icon icon="info-circle" />
              Información Adicional
            </h6>
            <table class="detail-table">
              <tr>
                <td class="label">ID Giro:</td>
                <td>{{ giroForm.id_giro }}</td>
              </tr>
              <tr>
                <td class="label">Cuenta Aplicable:</td>
                <td>{{ giroForm.ctaaplic || 'N/A' }}</td>
              </tr>
              <tr>
                <td class="label">Cuenta Aplicable REZ:</td>
                <td>{{ giroForm.ctaaplic_rez || 'N/A' }}</td>
              </tr>
            </table>
          </div>
        </div>
      </template>

      <template #footer>
        <button @click="cerrarModal" class="btn-municipal-secondary">
          <font-awesome-icon icon="times" /> Cerrar
        </button>
        <button
          v-if="modoEdicion === 'crear'"
          @click="guardarGiro"
          class="btn-municipal-success"
        >
          <font-awesome-icon icon="save" /> Crear Giro
        </button>
        <button
          v-if="modoEdicion === 'editar'"
          @click="actualizarGiro"
          class="btn-municipal-primary"
        >
          <font-awesome-icon icon="save" /> Guardar Cambios
        </button>
      </template>
    </Modal>
  </div>

    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showDocumentation"
      :componentName="'catalogogirosfrm'"
      :moduleName="'padron_licencias'"
      @close="closeDocumentation"
    />
  </template>

<script setup>
import DocumentationModal from '@/components/common/DocumentationModal.vue'

import { ref, computed, onMounted } from 'vue'
import { useApi } from '@/composables/useApi'
import Modal from '@/components/common/Modal.vue'
import Swal from 'sweetalert2'

const showDocumentation = ref(false)
const openDocumentation = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false

const { execute } = useApi()

// Estados
const loading = ref(false)
const giros = ref([])
const totalRegistros = ref(0)
const paginaActual = ref(1)
const registrosPorPagina = ref(25)
const mostrarModal = ref(false)
const modoEdicion = ref('ver') // 'ver', 'editar', 'crear'

// Filtros
const filters = ref({
  codigo: '',
  descripcion: '',
  clasificacion: '',
  tipo: '',
  vigente: 'V' // Por defecto mostrar solo vigentes
})

// Formulario de giro
const giroForm = ref({
  id_giro: null,
  cod_giro: null,
  cod_anun: '',
  descripcion: '',
  caracteristicas: '',
  clasificacion: 'B',
  tipo: 'L',
  reglamentada: 'N',
  vigente: 'V',
  ctaaplic: null,
  ctaaplic_rez: null
})

// Computed
const totalPaginas = computed(() => {
  return Math.ceil(totalRegistros.value / registrosPorPagina.value)
})

const visiblePages = computed(() => {
  const pages = []
  const maxVisible = 5
  let start = Math.max(1, paginaActual.value - Math.floor(maxVisible / 2))
  let end = Math.min(totalPaginas.value, start + maxVisible - 1)

  if (end - start < maxVisible - 1) {
    start = Math.max(1, end - maxVisible + 1)
  }

  for (let i = start; i <= end; i++) {
    pages.push(i)
  }
  return pages
})

const modalTitle = computed(() => {
  if (modoEdicion.value === 'crear') return 'Nuevo Giro'
  if (modoEdicion.value === 'editar') return 'Editar Giro'
  return 'Detalle del Giro'
})

// Métodos
const buscar = async () => {
  loading.value = true
  try {
    const response = await execute(
      'sp_catalogogiros_list',
      'padron_licencias',
      [
        { nombre: 'p_page', valor: paginaActual.value, tipo: 'integer' },
        { nombre: 'p_page_size', valor: registrosPorPagina.value, tipo: 'integer' },
        { nombre: 'p_codigo', valor: filters.value.codigo || null, tipo: 'string' },
        { nombre: 'p_descripcion', valor: filters.value.descripcion || null, tipo: 'string' },
        { nombre: 'p_clasificacion', valor: filters.value.clasificacion || null, tipo: 'string' },
        { nombre: 'p_tipo', valor: filters.value.tipo || null, tipo: 'string' },
        { nombre: 'p_vigente', valor: filters.value.vigente || null, tipo: 'string' }
      ],
      'guadalajara'
    )

    if (response && response.result && response.result.length > 0) {
      giros.value = response.result
      totalRegistros.value = parseInt(response.result[0].total_count)
    } else {
      giros.value = []
      totalRegistros.value = 0
    }
  } catch (error) {
    console.error('Error al buscar giros:', error)
    Swal.fire({
      icon: 'error',
      title: 'Error',
      text: 'No se pudieron cargar los giros',
      confirmButtonColor: '#ea8215'
    })
  } finally {
    loading.value = false
  }
}

const limpiarFiltros = () => {
  filters.value = {
    codigo: '',
    descripcion: '',
    clasificacion: '',
    tipo: '',
    vigente: 'V'
  }
  paginaActual.value = 1
  buscar()
}

const cambiarPagina = (nuevaPagina) => {
  if (nuevaPagina >= 1 && nuevaPagina <= totalPaginas.value) {
    paginaActual.value = nuevaPagina
    buscar()
  }
}

const cambiarTamanioPagina = () => {
  paginaActual.value = 1
  buscar()
}

const verDetalle = async (giro) => {
  loading.value = true
  try {
    const response = await execute(
      'sp_catalogogiros_get',
      'padron_licencias',
      [{ nombre: 'p_id_giro', valor: giro.id_giro, tipo: 'integer' }],
      'guadalajara'
    )

    if (response && response.result && response.result.length > 0) {
      giroForm.value = { ...response.result[0] }
      modoEdicion.value = 'ver'
      mostrarModal.value = true
    }
  } catch (error) {
    console.error('Error al obtener detalle:', error)
    Swal.fire({
      icon: 'error',
      title: 'Error',
      text: 'No se pudo obtener el detalle del giro',
      confirmButtonColor: '#ea8215'
    })
  } finally {
    loading.value = false
  }
}

const editarGiro = async (giro) => {
  loading.value = true
  try {
    const response = await execute(
      'sp_catalogogiros_get',
      'padron_licencias',
      [{ nombre: 'p_id_giro', valor: giro.id_giro, tipo: 'integer' }],
      'guadalajara'
    )

    if (response && response.result && response.result.length > 0) {
      giroForm.value = { ...response.result[0] }
      modoEdicion.value = 'editar'
      mostrarModal.value = true
    }
  } catch (error) {
    console.error('Error al cargar giro:', error)
    Swal.fire({
      icon: 'error',
      title: 'Error',
      text: 'No se pudo cargar el giro para edición',
      confirmButtonColor: '#ea8215'
    })
  } finally {
    loading.value = false
  }
}

const abrirModalNuevo = () => {
  giroForm.value = {
    id_giro: null,
    cod_giro: null,
    cod_anun: '',
    descripcion: '',
    caracteristicas: '',
    clasificacion: 'B',
    tipo: 'L',
    reglamentada: 'N',
    vigente: 'V',
    ctaaplic: 216000000,
    ctaaplic_rez: 216000001
  }
  modoEdicion.value = 'crear'
  mostrarModal.value = true
}

const guardarGiro = async () => {
  // Validaciones
  if (!giroForm.value.cod_giro || giroForm.value.cod_giro <= 0) {
    Swal.fire({
      icon: 'warning',
      title: 'Validación',
      text: 'El código del giro es requerido',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  if (!giroForm.value.descripcion || giroForm.value.descripcion.trim() === '') {
    Swal.fire({
      icon: 'warning',
      title: 'Validación',
      text: 'La descripción es requerida',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  loading.value = true
  try {
    const response = await execute(
      'sp_catalogogiros_create',
      'padron_licencias',
      [
        { nombre: 'p_cod_giro', valor: giroForm.value.cod_giro, tipo: 'integer' },
        { nombre: 'p_cod_anun', valor: giroForm.value.cod_anun || null, tipo: 'string' },
        { nombre: 'p_descripcion', valor: giroForm.value.descripcion, tipo: 'string' },
        { nombre: 'p_caracteristicas', valor: giroForm.value.caracteristicas || null, tipo: 'string' },
        { nombre: 'p_clasificacion', valor: giroForm.value.clasificacion, tipo: 'string' },
        { nombre: 'p_tipo', valor: giroForm.value.tipo, tipo: 'string' },
        { nombre: 'p_reglamentada', valor: giroForm.value.reglamentada, tipo: 'string' },
        { nombre: 'p_ctaaplic', valor: 216000000, tipo: 'integer' },
        { nombre: 'p_vigente', valor: giroForm.value.vigente, tipo: 'string' }
      ],
      'guadalajara'
    )

    if (response && response.result && response.result[0]?.success) {
      await Swal.fire({
        icon: 'success',
        title: 'Éxito',
        text: response.result[0].message,
        confirmButtonColor: '#ea8215'
      })
      cerrarModal()
      buscar()
    } else {
      Swal.fire({
        icon: 'error',
        title: 'Error',
        text: response.result[0]?.message || 'No se pudo crear el giro',
        confirmButtonColor: '#ea8215'
      })
    }
  } catch (error) {
    console.error('Error al crear giro:', error)
    Swal.fire({
      icon: 'error',
      title: 'Error',
      text: 'Ocurrió un error al crear el giro',
      confirmButtonColor: '#ea8215'
    })
  } finally {
    loading.value = false
  }
}

const actualizarGiro = async () => {
  // Validaciones
  if (!giroForm.value.cod_giro || giroForm.value.cod_giro <= 0) {
    Swal.fire({
      icon: 'warning',
      title: 'Validación',
      text: 'El código del giro es requerido',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  if (!giroForm.value.descripcion || giroForm.value.descripcion.trim() === '') {
    Swal.fire({
      icon: 'warning',
      title: 'Validación',
      text: 'La descripción es requerida',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  loading.value = true
  try {
    const response = await execute(
      'sp_catalogogiros_update',
      'padron_licencias',
      [
        { nombre: 'p_id_giro', valor: giroForm.value.id_giro, tipo: 'integer' },
        { nombre: 'p_cod_giro', valor: giroForm.value.cod_giro, tipo: 'integer' },
        { nombre: 'p_cod_anun', valor: giroForm.value.cod_anun || null, tipo: 'string' },
        { nombre: 'p_descripcion', valor: giroForm.value.descripcion, tipo: 'string' },
        { nombre: 'p_caracteristicas', valor: giroForm.value.caracteristicas || null, tipo: 'string' },
        { nombre: 'p_clasificacion', valor: giroForm.value.clasificacion, tipo: 'string' },
        { nombre: 'p_tipo', valor: giroForm.value.tipo, tipo: 'string' },
        { nombre: 'p_reglamentada', valor: giroForm.value.reglamentada, tipo: 'string' },
        { nombre: 'p_vigente', valor: giroForm.value.vigente, tipo: 'string' }
      ],
      'guadalajara'
    )

    if (response && response.result && response.result[0]?.success) {
      await Swal.fire({
        icon: 'success',
        title: 'Éxito',
        text: response.result[0].message,
        confirmButtonColor: '#ea8215'
      })
      cerrarModal()
      buscar()
    } else {
      Swal.fire({
        icon: 'error',
        title: 'Error',
        text: response.result[0]?.message || 'No se pudo actualizar el giro',
        confirmButtonColor: '#ea8215'
      })
    }
  } catch (error) {
    console.error('Error al actualizar giro:', error)
    Swal.fire({
      icon: 'error',
      title: 'Error',
      text: 'Ocurrió un error al actualizar el giro',
      confirmButtonColor: '#ea8215'
    })
  } finally {
    loading.value = false
  }
}

const cambiarVigencia = async (giro, nuevaVigencia) => {
  const accion = nuevaVigencia === 'V' ? 'reactivar' : 'cancelar'

  const result = await Swal.fire({
    icon: 'question',
    title: `¿${accion === 'reactivar' ? 'Reactivar' : 'Cancelar'} Giro?`,
    text: `¿Está seguro de ${accion} el giro "${giro.descripcion}"?`,
    showCancelButton: true,
    confirmButtonText: 'Sí, continuar',
    confirmButtonColor: '#ea8215',
    cancelButtonText: 'Cancelar'
  })

  if (!result.isConfirmed) return

  loading.value = true
  try {
    const response = await execute(
      'sp_catalogogiros_cambiar_vigencia',
      'padron_licencias',
      [
        { nombre: 'p_id_giro', valor: giro.id_giro, tipo: 'integer' },
        { nombre: 'p_vigente', valor: nuevaVigencia, tipo: 'string' }
      ],
      'guadalajara'
    )

    if (response && response.result && response.result[0]?.success) {
      await Swal.fire({
        icon: 'success',
        title: 'Éxito',
        text: response.result[0].message,
        confirmButtonColor: '#ea8215'
      })
      buscar()
    } else {
      Swal.fire({
        icon: 'error',
        title: 'Error',
        text: response.result[0]?.message || 'No se pudo cambiar la vigencia',
        confirmButtonColor: '#ea8215'
      })
    }
  } catch (error) {
    console.error('Error al cambiar vigencia:', error)
    Swal.fire({
      icon: 'error',
      title: 'Error',
      text: 'Ocurrió un error al cambiar la vigencia',
      confirmButtonColor: '#ea8215'
    })
  } finally {
    loading.value = false
  }
}

const cerrarModal = () => {
  mostrarModal.value = false
  modoEdicion.value = 'ver'
  giroForm.value = {
    id_giro: null,
    cod_giro: null,
    cod_anun: '',
    descripcion: '',
    caracteristicas: '',
    clasificacion: 'B',
    tipo: 'L',
    reglamentada: 'N',
    vigente: 'V',
    ctaaplic: null,
    ctaaplic_rez: null
  }
}

// Lifecycle
onMounted(() => {
  buscar()
})
</script>

<style scoped>
.btn-group-actions {
  display: flex;
  gap: 0.5rem;
}

.btn-group-actions button {
  flex: 1;
}
</style>
