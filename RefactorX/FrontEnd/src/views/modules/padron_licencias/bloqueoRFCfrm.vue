<template>
  <div class="module-view">
    <!-- Header -->
    <div class="module-view-header" style="position: relative;">
      <div class="module-view-icon">
        <font-awesome-icon icon="ban" />
      </div>
      <div class="module-view-info">
        <h1>Bloqueo de RFC</h1>
        <p>Bloqueo de RFC por incumplimiento del programa de autoevaluación</p></div>
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
      <!-- Buscar y Crear Nuevo Bloqueo -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5 class="municipal-card-title">
            <font-awesome-icon icon="plus-circle" />
            Registrar Nuevo Bloqueo de RFC
          </h5>
        </div>
        <div class="municipal-card-body">
          <form @submit.prevent="buscarTramite">
            <div class="form-row">
              <div class="form-group col-md-4">
                <label class="municipal-form-label">Número de Trámite:</label>
                <input
                  type="number"
                  class="municipal-form-control"
                  v-model.number="idTramiteBuscar"
                  placeholder="Ingrese ID del trámite"
                  required
                />
              </div>
              <div class="form-group col-md-2">
                <label class="municipal-form-label">&nbsp;</label>
                <button
                  type="submit"
                  class="btn-municipal-primary w-100"
                  :disabled="loading"
                >
                  <font-awesome-icon icon="search" /> Buscar
                </button>
              </div>
            </div>
          </form>

          <!-- Información del trámite encontrado -->
          <div v-if="tramiteInfo" class="mt-3 p-3" style="background: #ffffff; border: 1px solid var(--slate-200); border-radius: 8px;">
            <h6 class="mb-3"><strong>Información del Trámite</strong></h6>
            <div class="row">
              <div class="col-md-6">
                <p class="mb-2"><strong>RFC:</strong> {{ tramiteInfo.rfc }}</p>
                <p class="mb-2"><strong>Propietario:</strong> {{ tramiteInfo.propietario_completo }}</p>
              </div>
              <div class="col-md-6">
                <p class="mb-2"><strong>Licencia:</strong> {{ tramiteInfo.id_licencia || 'N/A' }}</p>
                <p class="mb-2"><strong>Actividad:</strong> {{ tramiteInfo.actividad }}</p>
              </div>
            </div>
            <div class="form-row mt-3">
              <div class="form-group col-md-12">
                <label class="municipal-form-label">Motivo del Bloqueo:</label>
                <textarea
                  class="municipal-form-control"
                  v-model="nuevoBloqueo.observacion"
                  rows="2"
                  placeholder="Ingrese el motivo del bloqueo del RFC"
                  required
                ></textarea>
              </div>
            </div>
            <button
              type="button"
              class="btn-municipal-danger mt-2"
              @click="crearBloqueo"
              :disabled="loading || !nuevoBloqueo.observacion"
            >
              <font-awesome-icon icon="lock" /> Registrar Bloqueo
            </button>
            <button
              type="button"
              class="btn-municipal-secondary ms-2 mt-2"
              @click="limpiarFormulario"
            >
              <font-awesome-icon icon="eraser" /> Cancelar
            </button>
          </div>
        </div>
      </div>

      <!-- Filtros -->
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
              <label class="municipal-form-label">Buscar por RFC:</label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="filtros.rfc"
                placeholder="RFC..."
                @input="cargarBloqueos"
              />
            </div>
            <div class="form-group col-md-3">
              <label class="municipal-form-label">Vigencia:</label>
              <select class="municipal-form-control" v-model="filtros.vigente" @change="cargarBloqueos">
                <option value="">Todos</option>
                <option value="V">Vigentes</option>
                <option value="C">Cancelados</option>
              </select>
            </div>
            <div class="form-group col-md-3">
              <label class="municipal-form-label">Registros por página:</label>
              <select class="municipal-form-control" v-model.number="pageSize" @change="cargarBloqueos">
                <option :value="10">10</option>
                <option :value="25">25</option>
                <option :value="50">50</option>
                <option :value="100">100</option>
              </select>
            </div>
          </div>
        </div>
      </div>

      <!-- Tabla de Bloqueos RFC -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5 class="municipal-card-title">
            <font-awesome-icon icon="list" />
            Listado de Bloqueos RFC
            <span class="badge badge-primary ms-2" v-if="totalRecords">
              {{ totalRecords.toLocaleString() }} registro(s)
            </span>
          </h5>
        </div>
        <div class="municipal-card-body p-0">
          <div class="table-responsive">
            <table class="table table-hover mb-0">
              <thead>
                <tr>
                  <th>RFC</th>
                  <th>Trámite</th>
                  <th>Licencia</th>
                  <th>Propietario</th>
                  <th>Actividad</th>
                  <th>Vigente</th>
                  <th>Fecha/Hora</th>
                  <th>Capturista</th>
                  <th>Observación</th>
                  <th>Acciones</th>
                </tr>
              </thead>
              <tbody>
                <tr v-if="loading">
                  <td colspan="10" class="text-center py-4">
                    <div class="spinner-border text-primary" role="status">
                      <span class="visually-hidden">Cargando...</span>
                    </div>
                  </td>
                </tr>
                <tr v-else-if="bloqueos.length === 0">
                  <td colspan="10" class="text-center py-4 text-muted">
                    No se encontraron registros
                  </td>
                </tr>
                <tr v-else v-for="bloqueo in bloqueos" :key="`${bloqueo.rfc}-${bloqueo.id_tramite}`">
                  <td><strong>{{ bloqueo.rfc }}</strong></td>
                  <td>{{ bloqueo.id_tramite }}</td>
                  <td>{{ bloqueo.licencia || 'N/A' }}</td>
                  <td>{{ bloqueo.propietario_completo }}</td>
                  <td class="small">{{ bloqueo.actividad }}</td>
                  <td>
                    <span class="badge" :class="bloqueo.vig === 'V' ? 'badge-success' : 'badge-secondary'">
                      {{ bloqueo.vig === 'V' ? 'Vigente' : 'Cancelado' }}
                    </span>
                  </td>
                  <td class="small">{{ formatDateTime(bloqueo.hora) }}</td>
                  <td>{{ bloqueo.capturista }}</td>
                  <td class="small">{{ bloqueo.observacion }}</td>
                  <td>
                    <div class="btn-group">
                      <button
                        v-if="bloqueo.vig === 'V'"
                        class="btn-action btn-success"
                        @click="confirmarDesbloqueo(bloqueo)"
                        :disabled="loading"
                        title="Desbloquear RFC"
                      >
                        <font-awesome-icon icon="unlock" />
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
      :componentName="'bloqueoRFCfrm'"
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

const idTramiteBuscar = ref(null)
const tramiteInfo = ref(null)

const nuevoBloqueo = ref({
  observacion: ''
})

const filtros = ref({
  rfc: '',
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
      'sp_bloqueorfc_list',
      'padron_licencias',
      [
        { nombre: 'p_page', valor: currentPage.value, tipo: 'integer' },
        { nombre: 'p_page_size', valor: pageSize.value, tipo: 'integer' },
        { nombre: 'p_rfc', valor: filtros.value.rfc || null, tipo: 'string' },
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
    console.error('Error al cargar bloqueos RFC:', error)
    Swal.fire({
      icon: 'error',
      title: 'Error',
      text: 'No se pudieron cargar los bloqueos de RFC',
      confirmButtonColor: '#ea8215'
    })
  } finally {
    loading.value = false
  }
}

const buscarTramite = async () => {
  if (!idTramiteBuscar.value) return

  loading.value = true
  try {
    const response = await execute(
      'sp_bloqueorfc_buscar_tramite',
      'padron_licencias',
      [{ nombre: 'p_id_tramite', valor: idTramiteBuscar.value, tipo: 'integer' }],
      'guadalajara'
    )

    if (response && response.result && response.result.length > 0) {
      tramiteInfo.value = response.result[0]

      if (!tramiteInfo.value.rfc || tramiteInfo.value.rfc.trim() === '') {
        Swal.fire({
          icon: 'warning',
          title: 'RFC no encontrado',
          text: 'El trámite no tiene RFC registrado',
          confirmButtonColor: '#ea8215'
        })
        tramiteInfo.value = null
      }
    } else {
      Swal.fire({
        icon: 'error',
        title: 'No encontrado',
        text: 'El trámite no existe en el sistema',
        confirmButtonColor: '#ea8215'
      })
      tramiteInfo.value = null
    }
  } catch (error) {
    console.error('Error al buscar trámite:', error)
    Swal.fire({
      icon: 'error',
      title: 'Error',
      text: 'No se pudo buscar el trámite',
      confirmButtonColor: '#ea8215'
    })
  } finally {
    loading.value = false
  }
}

const crearBloqueo = async () => {
  if (!nuevoBloqueo.value.observacion.trim()) {
    Swal.fire({
      icon: 'warning',
      title: 'Motivo requerido',
      text: 'Debe ingresar el motivo del bloqueo',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  const confirmacion = await Swal.fire({
    icon: 'warning',
    title: '¿Bloquear RFC?',
    html: `
      <p>¿Está seguro de bloquear el RFC <strong>${tramiteInfo.value.rfc}</strong>?</p>
      <p><strong>Trámite:</strong> ${idTramiteBuscar.value}</p>
      <p><strong>Propietario:</strong> ${tramiteInfo.value.propietario_completo}</p>
      <p><strong>Motivo:</strong> ${nuevoBloqueo.value.observacion}</p>
    `,
    showCancelButton: true,
    confirmButtonColor: '#dc3545',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, bloquear',
    cancelButtonText: 'Cancelar'
  })

  if (!confirmacion.isConfirmed) return

  loading.value = true
  try {
    const response = await execute(
      'sp_bloqueorfc_create',
      'padron_licencias',
      [
        { nombre: 'p_id_tramite', valor: idTramiteBuscar.value, tipo: 'integer' },
        { nombre: 'p_observacion', valor: nuevoBloqueo.value.observacion, tipo: 'string' },
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

const confirmarDesbloqueo = async (bloqueo) => {
  const { value: motivo } = await Swal.fire({
    title: 'Desbloquear RFC',
    html: `
      <p>¿Está seguro de desbloquear el RFC <strong>${bloqueo.rfc}</strong>?</p>
      <p><strong>Propietario:</strong> ${bloqueo.propietario_completo}</p>
      <textarea id="swal-motivo" class="swal2-textarea" placeholder="Motivo del desbloqueo..." rows="3"></textarea>
    `,
    focusConfirm: false,
    showCancelButton: true,
    confirmButtonColor: '#28a745',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, desbloquear',
    cancelButtonText: 'Cancelar',
    preConfirm: () => {
      const motivo = document.getElementById('swal-motivo').value
      if (!motivo || !motivo.trim()) {
        Swal.showValidationMessage('Debe ingresar el motivo del desbloqueo')
      }
      return motivo
    }
  })

  if (!motivo) return

  loading.value = true
  try {
    const response = await execute(
      'sp_bloqueorfc_desbloquear',
      'padron_licencias',
      [
        { nombre: 'p_rfc', valor: bloqueo.rfc, tipo: 'string' },
        { nombre: 'p_id_tramite', valor: bloqueo.id_tramite, tipo: 'integer' },
        { nombre: 'p_motivo', valor: motivo, tipo: 'string' }
      ],
      'guadalajara'
    )

    if (response && response.result && response.result.length > 0) {
      const resultado = response.result[0]

      if (resultado.success) {
        await Swal.fire({
          icon: 'success',
          title: 'RFC Desbloqueado',
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
    console.error('Error al desbloquear RFC:', error)
    Swal.fire({
      icon: 'error',
      title: 'Error',
      text: 'No se pudo desbloquear el RFC',
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
  idTramiteBuscar.value = null
  tramiteInfo.value = null
  nuevoBloqueo.value = {
    observacion: ''
  }
}

const formatDateTime = (datetime) => {
  if (!datetime) return 'N/A'
  const d = new Date(datetime)
  return d.toLocaleString('es-MX')
}

// Cargar al montar
onMounted(() => {
  cargarBloqueos()
})
</script>
