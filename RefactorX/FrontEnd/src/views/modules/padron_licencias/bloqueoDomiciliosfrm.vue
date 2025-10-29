<template>
  <div class="module-view">
    <!-- Header -->
    <div class="module-view-header" style="position: relative;">
      <div class="module-view-icon">
        <font-awesome-icon icon="lock" />
      </div>
      <div class="module-view-info">
        <h1>Bloqueo de Domicilios</h1>
        <p>Gestión de bloqueos y desbloqueos de licencias, anuncios y trámites</p></div>
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
      <!-- Crear Nuevo Bloqueo -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5 class="municipal-card-title">
            <font-awesome-icon icon="plus-circle" />
            Registrar Nuevo Bloqueo
          </h5>
        </div>
        <div class="municipal-card-body">
          <form @submit.prevent="crearBloqueo">
            <div class="form-row">
              <div class="form-group col-md-3">
                <label class="municipal-form-label">Tipo de Registro:</label>
                <select
                  class="municipal-form-control"
                  v-model="nuevoBloqueo.tipo"
                  required
                >
                  <option value="">Seleccionar...</option>
                  <option value="Licencia">Licencia</option>
                  <option value="Anuncio">Anuncio</option>
                  <option value="Tramite">Trámite</option>
                </select>
              </div>
              <div class="form-group col-md-3">
                <label class="municipal-form-label">Número de {{ nuevoBloqueo.tipo || 'Registro' }}:</label>
                <input
                  type="number"
                  class="municipal-form-control"
                  v-model.number="nuevoBloqueo.idRegistro"
                  :placeholder="'Ingrese número de ' + (nuevoBloqueo.tipo || 'registro')"
                  required
                />
              </div>
              <div class="form-group col-md-6">
                <label class="municipal-form-label">Observaciones:</label>
                <input
                  type="text"
                  class="municipal-form-control"
                  v-model="nuevoBloqueo.observaciones"
                  placeholder="Motivo del bloqueo"
                  required
                />
              </div>
            </div>
            <div class="form-row">
              <div class="form-group col-md-12">
                <button
                  type="submit"
                  class="btn-municipal-danger"
                  :disabled="loading"
                >
                  <font-awesome-icon icon="lock" /> Registrar Bloqueo
                </button>
                <button
                  type="button"
                  class="btn-municipal-secondary ms-2"
                  @click="limpiarFormulario"
                >
                  <font-awesome-icon icon="eraser" /> Limpiar
                </button>
              </div>
            </div>
          </form>
        </div>
      </div>

      <!-- Filtros y Búsqueda -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5 class="municipal-card-title">
            <font-awesome-icon icon="filter" />
            Filtros de Búsqueda
          </h5>
        </div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group col-md-3">
              <label class="municipal-form-label">Tipo:</label>
              <select class="municipal-form-control" v-model="filtros.tipo" @change="cargarBloqueos">
                <option value="">Todos</option>
                <option value="Licencia">Licencia</option>
                <option value="Anuncio">Anuncio</option>
                <option value="Tramite">Trámite</option>
              </select>
            </div>
            <div class="form-group col-md-3">
              <label class="municipal-form-label">Estado:</label>
              <select class="municipal-form-control" v-model="filtros.estado" @change="cargarBloqueos">
                <option value="">Todos</option>
                <option value="bloqueado">Bloqueado</option>
                <option value="desbloqueado">Desbloqueado</option>
              </select>
            </div>
            <div class="form-group col-md-3">
              <label class="municipal-form-label">Vigencia:</label>
              <select class="municipal-form-control" v-model="filtros.vigente" @change="cargarBloqueos">
                <option value="">Todos</option>
                <option value="V">Vigentes</option>
                <option value="C">Cancelados</option>
              </select>
            </div>
          </div>
        </div>
      </div>

      <!-- Tabla de Bloqueos -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5 class="municipal-card-title">
            <font-awesome-icon icon="list" />
            Listado de Bloqueos
            <span class="badge badge-primary ms-2" v-if="totalRecords">
              {{ totalRecords.toLocaleString() }} registros
            </span>
          </h5>
        </div>
        <div class="municipal-card-body p-0">
          <div class="table-responsive">
            <table class="table table-hover mb-0">
              <thead>
                <tr>
                  <th>Tipo</th>
                  <th>Número</th>
                  <th>Estado</th>
                  <th>Vigente</th>
                  <th>Fecha</th>
                  <th>Capturista</th>
                  <th>Observaciones</th>
                  <th>Acciones</th>
                </tr>
              </thead>
              <tbody>
                <tr v-if="loading">
                  <td colspan="8" class="text-center py-4">
                    <div class="spinner-border text-primary" role="status">
                      <span class="visually-hidden">Cargando...</span>
                    </div>
                  </td>
                </tr>
                <tr v-else-if="bloqueos.length === 0">
                  <td colspan="8" class="text-center py-4 text-muted">
                    No se encontraron registros
                  </td>
                </tr>
                <tr v-else v-for="bloqueo in bloqueos" :key="`${bloqueo.tipo_registro}-${bloqueo.numero_registro}`">
                  <td>
                    <span class="badge" :class="{
                      'badge-primary': bloqueo.tipo_registro === 'Licencia',
                      'badge-info': bloqueo.tipo_registro === 'Anuncio',
                      'badge-warning': bloqueo.tipo_registro === 'Tramite'
                    }">
                      {{ bloqueo.tipo_registro }}
                    </span>
                  </td>
                  <td><strong>{{ bloqueo.numero_registro }}</strong></td>
                  <td>
                    <span class="badge" :class="bloqueo.bloqueado ? 'badge-danger' : 'badge-success'">
                      {{ bloqueo.bloqueado ? 'Bloqueado' : 'Desbloqueado' }}
                    </span>
                  </td>
                  <td>
                    <span class="badge" :class="bloqueo.vigente === 'V' ? 'badge-success' : 'badge-secondary'">
                      {{ bloqueo.vigente === 'V' ? 'Vigente' : 'Cancelado' }}
                    </span>
                  </td>
                  <td>{{ formatDate(bloqueo.fecha_mov) }}</td>
                  <td>{{ bloqueo.capturista }}</td>
                  <td class="small">{{ bloqueo.observa }}</td>
                  <td>
                    <div class="btn-group">
                      <button
                        v-if="bloqueo.vigente === 'V'"
                        class="btn-action btn-danger"
                        @click="confirmarCancelacion(bloqueo)"
                        :disabled="loading"
                        title="Cancelar bloqueo"
                      >
                        <font-awesome-icon icon="times" />
                      </button>
                      <span v-else class="text-muted small">-</span>
                    </div>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>

          <!-- Paginación -->
          <div class="pagination-container" v-if="totalRecords > 0 && !loading">
            <div class="pagination-info">
              <font-awesome-icon icon="info-circle" />
              Mostrando {{ ((currentPage - 1) * pageSize) + 1 }}
              a {{ Math.min(currentPage * pageSize, totalRecords) }}
              de {{ totalRecords }} registros
            </div>

            <div class="pagination-controls">
              <div class="page-size-selector">
                <label>Mostrar:</label>
                <select v-model="pageSize" @change="cargarBloqueos">
                  <option :value="10">10</option>
                  <option :value="25">25</option>
                  <option :value="50">50</option>
                  <option :value="100">100</option>
                </select>
              </div>

              <div class="pagination-nav">
                <button
                  class="pagination-button"
                  @click="cambiarPagina(currentPage - 1)"
                  :disabled="currentPage === 1"
                >
                  <font-awesome-icon icon="chevron-left" />
                </button>

                <button
                  v-for="page in visiblePages"
                  :key="page"
                  class="pagination-button"
                  :class="{ active: page === currentPage }"
                  @click="cambiarPagina(page)"
                >
                  {{ page }}
                </button>

                <button
                  class="pagination-button"
                  @click="cambiarPagina(currentPage + 1)"
                  :disabled="currentPage === totalPages"
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
        <p>Procesando...</p>
      </div>
    </div>
  </div>

    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showDocumentation"
      :componentName="'bloqueoDomiciliosfrm'"
      :moduleName="'padron_licencias'"
      @close="closeDocumentation"
    />
  </template>

<script setup>
import DocumentationModal from '@/components/common/DocumentationModal.vue'

import { ref, computed, onMounted } from 'vue'
import { useApi } from '@/composables/useApi'
import Swal from 'sweetalert2'

const showDocumentation = ref(false)
const openDocumentation = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false

const { execute } = useApi()

// Estado
const bloqueos = ref([])
const loading = ref(false)
const currentPage = ref(1)
const pageSize = ref(25)
const totalRecords = ref(0)

const nuevoBloqueo = ref({
  tipo: '',
  idRegistro: null,
  observaciones: ''
})

const filtros = ref({
  tipo: '',
  estado: '',
  vigente: 'V'
})

// Computed
const totalPages = computed(() => {
  return Math.ceil(totalRecords.value / pageSize.value)
})

const visiblePages = computed(() => {
  const pages = []
  const maxVisible = 5
  let start = Math.max(1, currentPage.value - Math.floor(maxVisible / 2))
  let end = Math.min(totalPages.value, start + maxVisible - 1)

  if (end - start < maxVisible - 1) {
    start = Math.max(1, end - maxVisible + 1)
  }

  for (let i = start; i <= end; i++) {
    pages.push(i)
  }
  return pages
})

// Métodos
const cargarBloqueos = async () => {
  loading.value = true
  try {
    const response = await execute(
      'sp_bloqueodomicilios_list',
      'padron_licencias',
      [
        { nombre: 'p_page', valor: currentPage.value, tipo: 'integer' },
        { nombre: 'p_page_size', valor: pageSize.value, tipo: 'integer' },
        { nombre: 'p_tipo', valor: filtros.value.tipo || null, tipo: 'string' },
        { nombre: 'p_estado', valor: filtros.value.estado || null, tipo: 'string' },
        { nombre: 'p_vigente', valor: filtros.value.vigente || null, tipo: 'string' }
      ],
      'guadalajara'
    )

    if (response && response.result) {
      bloqueos.value = response.result
      if (response.result.length > 0) {
        totalRecords.value = parseInt(response.result[0].total_count)
      } else {
        totalRecords.value = 0
      }
    }
  } catch (error) {
    console.error('Error al cargar bloqueos:', error)
    Swal.fire({
      icon: 'error',
      title: 'Error',
      text: 'No se pudieron cargar los bloqueos',
      confirmButtonColor: '#ea8215'
    })
  } finally {
    loading.value = false
  }
}

const crearBloqueo = async () => {
  loading.value = true
  try {
    const response = await execute(
      'sp_bloqueodomicilios_create',
      'padron_licencias',
      [
        { nombre: 'p_tipo', valor: nuevoBloqueo.value.tipo, tipo: 'string' },
        { nombre: 'p_id_registro', valor: nuevoBloqueo.value.idRegistro, tipo: 'integer' },
        { nombre: 'p_observa', valor: nuevoBloqueo.value.observaciones, tipo: 'string' },
        { nombre: 'p_usuario', valor: 'sistema', tipo: 'string' }
      ],
      'guadalajara'
    )

    if (response && response.result && response.result.length > 0) {
      const resultado = response.result[0]

      if (resultado.success) {
        await Swal.fire({
          icon: 'success',
          title: 'Bloqueo Registrado',
          text: resultado.message,
          confirmButtonColor: '#ea8215',
          timer: 2000
        })

        limpiarFormulario()
        cargarBloqueos()
      } else {
        Swal.fire({
          icon: 'error',
          title: 'Error',
          text: resultado.message,
          confirmButtonColor: '#ea8215'
        })
      }
    }
  } catch (error) {
    console.error('Error al crear bloqueo:', error)
    Swal.fire({
      icon: 'error',
      title: 'Error',
      text: 'No se pudo registrar el bloqueo',
      confirmButtonColor: '#ea8215'
    })
  } finally {
    loading.value = false
  }
}

const confirmarCancelacion = async (bloqueo) => {
  const { value: motivo } = await Swal.fire({
    title: 'Cancelar Bloqueo',
    html: `
      <p>¿Está seguro de cancelar el bloqueo de <strong>${bloqueo.tipo_registro} #${bloqueo.numero_registro}</strong>?</p>
      <textarea id="swal-motivo" class="swal2-textarea" placeholder="Motivo de la cancelación..." rows="3"></textarea>
    `,
    focusConfirm: false,
    showCancelButton: true,
    confirmButtonColor: '#dc3545',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, cancelar',
    cancelButtonText: 'No',
    preConfirm: () => {
      const motivo = document.getElementById('swal-motivo').value
      if (!motivo || !motivo.trim()) {
        Swal.showValidationMessage('Debe ingresar el motivo de la cancelación')
      }
      return motivo
    }
  })

  if (!motivo) return

  loading.value = true
  try {
    const response = await execute(
      'sp_bloqueodomicilios_cancel',
      'padron_licencias',
      [
        { nombre: 'p_tipo', valor: bloqueo.tipo_registro, tipo: 'string' },
        { nombre: 'p_id_registro', valor: bloqueo.numero_registro, tipo: 'integer' },
        { nombre: 'p_motivo', valor: motivo, tipo: 'string' }
      ],
      'guadalajara'
    )

    if (response && response.result && response.result.length > 0) {
      const resultado = response.result[0]

      if (resultado.success) {
        await Swal.fire({
          icon: 'success',
          title: 'Cancelado',
          text: resultado.message,
          confirmButtonColor: '#ea8215',
          timer: 2000
        })

        cargarBloqueos()
      } else {
        Swal.fire({
          icon: 'error',
          title: 'Error',
          text: resultado.message,
          confirmButtonColor: '#ea8215'
        })
      }
    }
  } catch (error) {
    console.error('Error al cancelar bloqueo:', error)
    Swal.fire({
      icon: 'error',
      title: 'Error',
      text: 'No se pudo cancelar el bloqueo',
      confirmButtonColor: '#ea8215'
    })
  } finally {
    loading.value = false
  }
}

const cambiarPagina = (page) => {
  if (page >= 1 && page <= totalPages.value) {
    currentPage.value = page
    cargarBloqueos()
  }
}

const limpiarFormulario = () => {
  nuevoBloqueo.value = {
    tipo: '',
    idRegistro: null,
    observaciones: ''
  }
}

const formatDate = (date) => {
  if (!date) return 'N/A'
  const d = new Date(date)
  return d.toLocaleDateString('es-MX')
}

// Cargar al montar
onMounted(() => {
  cargarBloqueos()
})
</script>
