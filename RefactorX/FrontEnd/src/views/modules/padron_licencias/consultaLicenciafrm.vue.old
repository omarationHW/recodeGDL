<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header" style="position: relative;">
      <div class="module-view-icon">
        <font-awesome-icon icon="file-contract" />
      </div>
      <div class="module-view-info">
        <h1>Consulta de Licencias</h1>
        <p>Padrón de Licencias - Consulta y Gestión de Licencias</p></div>
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
      <!-- Búsqueda -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5 class="municipal-card-title">
            <font-awesome-icon icon="search" />
            Criterios de Búsqueda
          </h5>
        </div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">No. Licencia:</label>
              <div class="input-group">
                <input
                  type="text"
                  class="municipal-form-control"
                  v-model="searchForm.licencia"
                  placeholder="Ingrese número de licencia"
                  @keyup.enter="buscarPor('licencia')"
                />
                <button
                  class="btn-municipal-primary"
                  @click="buscarPor('licencia')"
                  :disabled="!searchForm.licencia || loading"
                >
                  <font-awesome-icon icon="search" /> Buscar
                </button>
              </div>
            </div>

            <div class="form-group">
              <label class="municipal-form-label">Ubicación:</label>
              <div class="input-group">
                <input
                  type="text"
                  class="municipal-form-control"
                  v-model="searchForm.ubicacion"
                  placeholder="Calle, colonia, etc."
                  @keyup.enter="buscarPor('ubicacion')"
                />
                <button
                  class="btn-municipal-primary"
                  @click="buscarPor('ubicacion')"
                  :disabled="!searchForm.ubicacion || loading"
                >
                  <font-awesome-icon icon="search" /> Buscar
                </button>
              </div>
            </div>
          </div>

          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Contribuyente/Propietario:</label>
              <div class="input-group">
                <input
                  type="text"
                  class="municipal-form-control"
                  v-model="searchForm.propietario"
                  placeholder="Nombre del propietario"
                  @keyup.enter="buscarPor('contribuyente')"
                />
                <button
                  class="btn-municipal-primary"
                  @click="buscarPor('contribuyente')"
                  :disabled="!searchForm.propietario || loading"
                >
                  <font-awesome-icon icon="search" /> Buscar
                </button>
              </div>
            </div>

            <div class="form-group">
              <label class="municipal-form-label">No. Trámite:</label>
              <div class="input-group">
                <input
                  type="number"
                  class="municipal-form-control"
                  v-model="searchForm.id_tramite"
                  placeholder="ID del trámite"
                  @keyup.enter="buscarPor('tramite')"
                />
                <button
                  class="btn-municipal-primary"
                  @click="buscarPor('tramite')"
                  :disabled="!searchForm.id_tramite || loading"
                >
                  <font-awesome-icon icon="search" /> Buscar
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Resultados -->
      <div class="municipal-card" v-if="licencias.length > 0 || searched">
        <div class="municipal-card-header">
          <h5 class="municipal-card-title">
            <font-awesome-icon icon="list" />
            Resultados de Búsqueda
            <span class="badge badge-primary ms-2" v-if="totalRecords > 0">
              {{ totalRecords }} registro(s)
            </span>
          </h5>
        </div>
        <div class="municipal-card-body">
          <div class="table-responsive" v-if="licencias.length > 0">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Licencia</th>
                  <th>Propietario</th>
                  <th>Ubicación</th>
                  <th>Actividad</th>
                  <th>Vigencia</th>
                  <th>Estado</th>
                  <th>Acciones</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="lic in licencias" :key="lic.id_licencia">
                  <td><strong>{{ lic.licencia }}</strong></td>
                  <td>{{ lic.propietario }}</td>
                  <td>{{ lic.ubicacion }}</td>
                  <td class="text-truncate" style="max-width: 200px">{{ lic.actividad }}</td>
                  <td>
                    <span :class="lic.vigente === 'S' ? 'badge-success' : 'badge-danger'" class="badge">
                      {{ lic.vigente === 'S' ? 'Vigente' : 'No Vigente' }}
                    </span>
                  </td>
                  <td>
                    <span v-if="lic.bloqueado > 0" class="badge badge-danger">
                      <font-awesome-icon icon="lock" /> Bloqueada
                    </span>
                    <span v-else class="badge badge-success">
                      <font-awesome-icon icon="unlock" /> Activa
                    </span>
                  </td>
                  <td>
                    <div class="btn-group">
                      <button
                        class="btn-action"
                        @click="verDetalle(lic)"
                        title="Ver detalle"
                      >
                        <font-awesome-icon icon="eye" />
                      </button>
                      <button
                        class="btn-action"
                        @click="verPagos(lic)"
                        title="Ver pagos"
                      >
                        <font-awesome-icon icon="money-bill" />
                      </button>
                      <button
                        class="btn-action"
                        @click="verAdeudos(lic)"
                        title="Ver adeudos"
                      >
                        <font-awesome-icon icon="file-invoice-dollar" />
                      </button>
                      <button
                        v-if="lic.bloqueado === 0"
                        class="btn-action btn-danger"
                        @click="bloquearLicencia(lic)"
                        title="Bloquear"
                      >
                        <font-awesome-icon icon="lock" />
                      </button>
                      <button
                        v-else
                        class="btn-action btn-success"
                        @click="desbloquearLicencia(lic)"
                        title="Desbloquear"
                      >
                        <font-awesome-icon icon="unlock" />
                      </button>
                    </div>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>

          <div v-else-if="searched && !loading" class="text-center text-muted py-4">
            <font-awesome-icon icon="inbox" size="3x" class="mb-3" />
            <p>No se encontraron licencias con los criterios especificados</p>
          </div>

          <!-- Paginación -->
          <div class="pagination-container" v-if="totalRecords > 0 && !loading">
            <div class="pagination-info">
              <font-awesome-icon icon="info-circle" />
              Mostrando {{ ((currentPage - 1) * itemsPerPage) + 1 }}
              a {{ Math.min(currentPage * itemsPerPage, totalRecords) }}
              de {{ totalRecords }} registros
            </div>

            <div class="pagination-controls">
              <div class="page-size-selector">
                <label>Mostrar:</label>
                <select v-model="itemsPerPage" @change="changePageSize">
                  <option :value="10">10</option>
                  <option :value="25">25</option>
                  <option :value="50">50</option>
                  <option :value="100">100</option>
                </select>
              </div>

              <div class="pagination-nav">
                <button
                  class="pagination-button"
                  @click="goToPage(currentPage - 1)"
                  :disabled="currentPage === 1"
                >
                  <font-awesome-icon icon="chevron-left" />
                </button>

                <button
                  v-for="page in visiblePages"
                  :key="page"
                  class="pagination-button"
                  :class="{ active: page === currentPage }"
                  @click="goToPage(page)"
                >
                  {{ page }}
                </button>

                <button
                  class="pagination-button"
                  @click="goToPage(currentPage + 1)"
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
        <p>Cargando licencias...</p>
      </div>
    </div>

    <!-- Modal de Detalle -->
    <Modal
      :show="showDetalleModal"
      :title="`Detalle de Licencia #${selectedLicencia?.licencia}`"
      size="xl"
      @close="showDetalleModal = false"
      :showDefaultFooter="false"
    >
      <div v-if="detalleLicencia" class="user-details">
        <div class="details-grid">
          <div class="detail-section">
            <h6 class="section-title">
              <font-awesome-icon icon="id-card" />
              Información General
            </h6>
            <table class="detail-table">
              <tr>
                <td class="label">Licencia:</td>
                <td><strong>{{ detalleLicencia.licencia }}</strong></td>
              </tr>
              <tr>
                <td class="label">Propietario:</td>
                <td>{{ detalleLicencia.propietario }}</td>
              </tr>
              <tr>
                <td class="label">RFC:</td>
                <td>{{ detalleLicencia.rfc || 'N/A' }}</td>
              </tr>
              <tr>
                <td class="label">CURP:</td>
                <td>{{ detalleLicencia.curp || 'N/A' }}</td>
              </tr>
              <tr>
                <td class="label">Email:</td>
                <td>{{ detalleLicencia.email || 'N/A' }}</td>
              </tr>
              <tr>
                <td class="label">Teléfono:</td>
                <td>{{ detalleLicencia.telefono_prop || 'N/A' }}</td>
              </tr>
            </table>
          </div>

          <div class="detail-section">
            <h6 class="section-title">
              <font-awesome-icon icon="map-marker-alt" />
              Ubicación
            </h6>
            <table class="detail-table">
              <tr>
                <td class="label">Ubicación:</td>
                <td>{{ detalleLicencia.ubicacion }}</td>
              </tr>
              <tr>
                <td class="label">Actividad:</td>
                <td>{{ detalleLicencia.actividad }}</td>
              </tr>
              <tr>
                <td class="label">Zona:</td>
                <td>{{ detalleLicencia.zona }}</td>
              </tr>
              <tr>
                <td class="label">Subzona:</td>
                <td>{{ detalleLicencia.subzona }}</td>
              </tr>
              <tr>
                <td class="label">Sup. Construida:</td>
                <td>{{ detalleLicencia.sup_construida }} m²</td>
              </tr>
              <tr>
                <td class="label">Empleados:</td>
                <td>{{ detalleLicencia.num_empleados || 0 }}</td>
              </tr>
            </table>
          </div>
        </div>

        <div class="details-grid mt-3">
          <div class="detail-section">
            <h6 class="section-title">
              <font-awesome-icon icon="calendar-alt" />
              Fechas
            </h6>
            <table class="detail-table">
              <tr>
                <td class="label">Fecha Otorgamiento:</td>
                <td>{{ formatDate(detalleLicencia.fecha_otorgamiento) }}</td>
              </tr>
              <tr>
                <td class="label">Fecha Baja:</td>
                <td>{{ formatDate(detalleLicencia.fecha_baja) }}</td>
              </tr>
            </table>
          </div>

          <div class="detail-section">
            <h6 class="section-title">
              <font-awesome-icon icon="info-circle" />
              Estado
            </h6>
            <table class="detail-table">
              <tr>
                <td class="label">Vigente:</td>
                <td>
                  <span :class="detalleLicencia.vigente === 'S' ? 'badge-success' : 'badge-danger'" class="badge">
                    {{ detalleLicencia.vigente === 'S' ? 'Sí' : 'No' }}
                  </span>
                </td>
              </tr>
              <tr>
                <td class="label">Bloqueada:</td>
                <td>
                  <span :class="detalleLicencia.bloqueado > 0 ? 'badge-danger' : 'badge-success'" class="badge">
                    {{ detalleLicencia.bloqueado > 0 ? 'Sí' : 'No' }}
                  </span>
                </td>
              </tr>
            </table>
          </div>
        </div>
      </div>
    </Modal>

    <!-- Modal de Pagos -->
    <Modal
      :show="showPagosModal"
      :title="`Pagos de Licencia #${selectedLicencia?.licencia}`"
      size="lg"
      @close="showPagosModal = false"
      :showDefaultFooter="false"
    >
      <div v-if="pagos.length > 0">
        <table class="municipal-table">
          <thead class="municipal-table-header">
            <tr>
              <th>Fecha</th>
              <th>Importe</th>
              <th>Cajero</th>
              <th>Folio</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="pago in pagos" :key="pago.cvepago">
              <td>{{ formatDate(pago.fecha) }}</td>
              <td>${{ Number(pago.importe).toFixed(2) }}</td>
              <td>{{ pago.cajero }}</td>
              <td>{{ pago.folio }}</td>
            </tr>
          </tbody>
        </table>
      </div>
      <div v-else class="text-center text-muted py-4">
        <font-awesome-icon icon="inbox" size="2x" class="mb-3" />
        <p>No hay pagos registrados</p>
      </div>
    </Modal>

    <!-- Modal de Adeudos -->
    <Modal
      :show="showAdeudosModal"
      :title="`Adeudos de Licencia #${selectedLicencia?.licencia}`"
      size="lg"
      @close="showAdeudosModal = false"
      :showDefaultFooter="false"
    >
      <div v-if="adeudos.length > 0">
        <table class="municipal-table">
          <thead class="municipal-table-header">
            <tr>
              <th>Año</th>
              <th>Derechos</th>
              <th>Recargos</th>
              <th>Formas</th>
              <th>Saldo</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="adeudo in adeudos" :key="adeudo.axo">
              <td><strong>{{ adeudo.axo }}</strong></td>
              <td>${{ Number(adeudo.derechos).toFixed(2) }}</td>
              <td>${{ Number(adeudo.recargos).toFixed(2) }}</td>
              <td>${{ Number(adeudo.formas).toFixed(2) }}</td>
              <td><strong>${{ Number(adeudo.saldo).toFixed(2) }}</strong></td>
            </tr>
          </tbody>
        </table>
        <div class="mt-3 text-end">
          <strong>Total Adeudo: ${{ totalAdeudo.toFixed(2) }}</strong>
        </div>
      </div>
      <div v-else class="text-center text-muted py-4">
        <font-awesome-icon icon="check-circle" size="2x" class="mb-3 text-success" />
        <p>No hay adeudos pendientes</p>
      </div>
    </Modal>
  </div>

    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showDocumentation"
      :componentName="'consultaLicenciafrm'"
      :moduleName="'padron_licencias'"
      @close="closeDocumentation"
    />
  </template>

<script setup>
import DocumentationModal from '@/components/common/DocumentationModal.vue'

import { ref, computed } from 'vue'
import { useApi } from '@/composables/useApi'
import Modal from '@/components/common/Modal.vue'
import Swal from 'sweetalert2'

const showDocumentation = ref(false)
const openDocumentation = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false

const { execute } = useApi()

// Estado
const searchForm = ref({
  licencia: '',
  ubicacion: '',
  propietario: '',
  id_tramite: null
})

const licencias = ref([])
const selectedLicencia = ref(null)
const detalleLicencia = ref(null)
const pagos = ref([])
const adeudos = ref([])
const loading = ref(false)
const searched = ref(false)

// Paginación
const currentPage = ref(1)
const itemsPerPage = ref(10)
const totalRecords = ref(0)
const lastSearchType = ref('')
const lastSearchValue = ref('')

// Modales
const showDetalleModal = ref(false)
const showPagosModal = ref(false)
const showAdeudosModal = ref(false)

// Computed
const totalPages = computed(() => Math.ceil(totalRecords.value / itemsPerPage.value))

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

const totalAdeudo = computed(() => {
  return adeudos.value.reduce((sum, adeudo) => sum + Number(adeudo.saldo), 0)
})

// Métodos
const buscarPor = async (tipo) => {
  let searchField = tipo
  let searchValue = ''
  let idTramite = null

  if (tipo === 'licencia') {
    if (!searchForm.value.licencia) return
    searchValue = searchForm.value.licencia
  } else if (tipo === 'ubicacion') {
    if (!searchForm.value.ubicacion) return
    searchValue = searchForm.value.ubicacion
  } else if (tipo === 'contribuyente') {
    if (!searchForm.value.propietario) return
    searchValue = searchForm.value.propietario
  } else if (tipo === 'tramite') {
    if (!searchForm.value.id_tramite) return
    idTramite = searchForm.value.id_tramite
    searchValue = String(idTramite)
  }

  lastSearchType.value = searchField
  lastSearchValue.value = searchValue
  currentPage.value = 1

  await loadLicencias()
}

const loadLicencias = async () => {
  loading.value = true
  searched.value = true

  try {
    const params = [
      { nombre: 'p_page', valor: currentPage.value, tipo: 'integer' },
      { nombre: 'p_page_size', valor: itemsPerPage.value, tipo: 'integer' },
      { nombre: 'p_search_field', valor: lastSearchType.value || null, tipo: 'string' },
      { nombre: 'p_search_value', valor: lastSearchValue.value || null, tipo: 'string' },
      { nombre: 'p_order_by', valor: 'licencia', tipo: 'string' },
      { nombre: 'p_id_tramite', valor: lastSearchType.value === 'tramite' ? parseInt(lastSearchValue.value) : null, tipo: 'integer' }
    ]

    console.log('Parámetros enviados a sp_consultalicencia_list:', params)

    const response = await execute(
      'sp_consultalicencia_list',
      'padron_licencias',
      params,
      'guadalajara'
    )

    console.log('Respuesta de sp_consultalicencia_list:', response)

    // Mostrar información de debug del backend
    if (response && response.debug) {
      console.log('🔍 Debug del backend:', response.debug)
      console.log('🔍 SQL ejecutado:', response.debug.sql_executed)
      console.log('🔍 Parámetros enviados al SP:', response.debug.parameters_sent)
    }

    if (response && response.result) {
      licencias.value = response.result
      console.log('Licencias encontradas:', response.result.length, response.result)
      if (response.result.length > 0) {
        totalRecords.value = response.result[0].total_count || 0
      } else {
        totalRecords.value = 0
      }
    }
  } catch (error) {
    console.error('Error al cargar licencias:', error)
    Swal.fire({
      icon: 'error',
      title: 'Error',
      text: 'No se pudieron cargar las licencias',
      confirmButtonColor: '#ea8215'
    })
  } finally {
    loading.value = false
  }
}

const verDetalle = async (licencia) => {
  selectedLicencia.value = licencia
  loading.value = true

  try {
    const response = await execute(
      'sp_consultalicencia_get',
      'padron_licencias',
      [{ nombre: 'p_id_licencia', valor: parseInt(licencia.id_licencia), tipo: 'integer' }],
      'guadalajara'
    )

    if (response && response.result && response.result.length > 0) {
      detalleLicencia.value = response.result[0]
      showDetalleModal.value = true
    }
  } catch (error) {
    console.error('Error al cargar detalle:', error)
    Swal.fire({
      icon: 'error',
      title: 'Error',
      text: 'No se pudo cargar el detalle de la licencia',
      confirmButtonColor: '#ea8215'
    })
  } finally {
    loading.value = false
  }
}

const verPagos = async (licencia) => {
  selectedLicencia.value = licencia
  loading.value = true

  try {
    const response = await execute(
      'sp_consultalicencia_get_pagos',
      'padron_licencias',
      [{ nombre: 'p_licencia', valor: parseInt(licencia.licencia), tipo: 'integer' }],
      'guadalajara'
    )

    if (response && response.result) {
      pagos.value = response.result
      showPagosModal.value = true
    }
  } catch (error) {
    console.error('Error al cargar pagos:', error)
    Swal.fire({
      icon: 'error',
      title: 'Error',
      text: 'No se pudieron cargar los pagos',
      confirmButtonColor: '#ea8215'
    })
  } finally {
    loading.value = false
  }
}

const verAdeudos = async (licencia) => {
  selectedLicencia.value = licencia
  loading.value = true

  try {
    const response = await execute(
      'sp_consultalicencia_get_adeudos',
      'padron_licencias',
      [
        { nombre: 'p_licencia', valor: parseInt(licencia.licencia), tipo: 'integer' },
        { nombre: 'p_tipo', valor: 'L', tipo: 'string' }
      ],
      'guadalajara'
    )

    if (response && response.result) {
      adeudos.value = response.result
      showAdeudosModal.value = true
    }
  } catch (error) {
    console.error('Error al cargar adeudos:', error)
    Swal.fire({
      icon: 'error',
      title: 'Error',
      text: 'No se pudieron cargar los adeudos',
      confirmButtonColor: '#ea8215'
    })
  } finally {
    loading.value = false
  }
}

const bloquearLicencia = async (licencia) => {
  const result = await Swal.fire({
    icon: 'warning',
    title: '¿Bloquear Licencia?',
    html: `
      <p>Está a punto de bloquear la licencia <strong>#${licencia.licencia}</strong></p>
      <textarea id="motivo-bloqueo" class="swal2-textarea" placeholder="Motivo del bloqueo (requerido)" rows="3"></textarea>
    `,
    showCancelButton: true,
    confirmButtonColor: '#dc3545',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, bloquear',
    cancelButtonText: 'Cancelar',
    preConfirm: () => {
      const motivo = document.getElementById('motivo-bloqueo').value
      if (!motivo) {
        Swal.showValidationMessage('Debe ingresar un motivo')
        return false
      }
      return motivo
    }
  })

  if (result.isConfirmed) {
    loading.value = true

    try {
      const response = await execute(
        'sp_consultalicencia_bloquear',
        'padron_licencias',
        [
          { nombre: 'p_licencia', valor: parseInt(licencia.licencia), tipo: 'integer' },
          { nombre: 'p_tipo_bloqueo', valor: 1, tipo: 'integer' },
          { nombre: 'p_motivo', valor: result.value, tipo: 'string' },
          { nombre: 'p_usuario', valor: 'sistema', tipo: 'string' }
        ],
        'guadalajara'
      )

      if (response && response.result && response.result[0]?.success) {
        await Swal.fire({
          icon: 'success',
          title: 'Licencia bloqueada',
          text: 'La licencia ha sido bloqueada correctamente',
          confirmButtonColor: '#ea8215',
          timer: 2000
        })
        loadLicencias()
      } else {
        throw new Error(response?.result?.[0]?.message || 'Error desconocido')
      }
    } catch (error) {
      console.error('Error al bloquear:', error)
      Swal.fire({
        icon: 'error',
        title: 'Error',
        text: 'No se pudo bloquear la licencia',
        confirmButtonColor: '#ea8215'
      })
    } finally {
      loading.value = false
    }
  }
}

const desbloquearLicencia = async (licencia) => {
  const result = await Swal.fire({
    icon: 'question',
    title: '¿Desbloquear Licencia?',
    html: `<p>¿Desea desbloquear la licencia <strong>#${licencia.licencia}</strong>?</p>`,
    showCancelButton: true,
    confirmButtonColor: '#ea8215',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, desbloquear',
    cancelButtonText: 'Cancelar'
  })

  if (result.isConfirmed) {
    loading.value = true

    try {
      const response = await execute(
        'sp_consultalicencia_desbloquear',
        'padron_licencias',
        [
          { nombre: 'p_licencia', valor: parseInt(licencia.licencia), tipo: 'integer' },
          { nombre: 'p_usuario', valor: 'sistema', tipo: 'string' }
        ],
        'guadalajara'
      )

      if (response && response.result && response.result[0]?.success) {
        await Swal.fire({
          icon: 'success',
          title: 'Licencia desbloqueada',
          text: 'La licencia ha sido desbloqueada correctamente',
          confirmButtonColor: '#ea8215',
          timer: 2000
        })
        loadLicencias()
      } else {
        throw new Error(response?.result?.[0]?.message || 'Error desconocido')
      }
    } catch (error) {
      console.error('Error al desbloquear:', error)
      Swal.fire({
        icon: 'error',
        title: 'Error',
        text: 'No se pudo desbloquear la licencia',
        confirmButtonColor: '#ea8215'
      })
    } finally {
      loading.value = false
    }
  }
}

const goToPage = (page) => {
  if (page >= 1 && page <= totalPages.value) {
    currentPage.value = page
    loadLicencias()
  }
}

const changePageSize = () => {
  currentPage.value = 1
  loadLicencias()
}

const formatDate = (date) => {
  if (!date) return 'N/A'
  const d = new Date(date)
  return d.toLocaleDateString('es-MX')
}
</script>
