<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header" style="position: relative;">
      <div class="module-view-icon">
        <font-awesome-icon icon="file-alt" />
      </div>
      <div class="module-view-info">
        <h1>Gestión de Constancias</h1>
        <p>Padrón de Licencias - Administración de Constancias</p></div>
      <button
        type="button"
        class="btn-help-icon"
        @click="openDocumentation"
        title="Ayuda"
      >
        <font-awesome-icon icon="question-circle" />
      </button>
      <div class="module-view-actions">
        <button
          class="btn-municipal-primary"
          @click="openCreateModal"
          :disabled="loading"
        >
          <font-awesome-icon icon="plus" />
          Nueva Constancia
        </button>
      </div>
    </div>

    <div class="module-view-content">

    <!-- Filtros de búsqueda -->
    <div class="municipal-card">
      <div class="municipal-card-body">
        <div class="form-row">
          <div class="form-group">
            <label class="municipal-form-label">Número de Licencia:</label>
            <div class="input-group">
              <input
                type="number"
                class="municipal-form-control"
                v-model="searchForm.licencia"
                placeholder="Número de licencia"
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
            <label class="municipal-form-label">Solicitante:</label>
            <div class="input-group">
              <input
                type="text"
                class="municipal-form-control"
                v-model="searchForm.solicita"
                placeholder="Nombre del solicitante"
                @keyup.enter="buscarPor('solicita')"
              />
              <button
                class="btn-municipal-primary"
                @click="buscarPor('solicita')"
                :disabled="!searchForm.solicita || loading"
              >
                <font-awesome-icon icon="search" /> Buscar
              </button>
            </div>
          </div>

          <div class="form-group">
            <label class="municipal-form-label">Partida de Pago:</label>
            <div class="input-group">
              <input
                type="text"
                class="municipal-form-control"
                v-model="searchForm.partidapago"
                placeholder="Número de partida"
                @keyup.enter="buscarPor('partidapago')"
              />
              <button
                class="btn-municipal-primary"
                @click="buscarPor('partidapago')"
                :disabled="!searchForm.partidapago || loading"
              >
                <font-awesome-icon icon="search" /> Buscar
              </button>
            </div>
          </div>

          <div class="form-group">
            <button
              class="btn-municipal-secondary"
              @click="loadAll"
              :disabled="loading"
              style="margin-top: 24px;"
            >
              <font-awesome-icon icon="list" /> Ver Todas
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Resultados -->
    <div v-if="constancias.length > 0" class="municipal-card">
      <div class="municipal-card-header">
        <h5 class="municipal-card-title">
          <font-awesome-icon icon="list" />
          Constancias Encontradas ({{ totalRecords }} registros)
        </h5>
      </div>
      <div class="municipal-card-body">
        <div class="table-responsive">
          <table class="municipal-table table-hover">
            <thead>
              <tr>
                <th>Año</th>
                <th>Folio</th>
                <th>Licencia</th>
                <th>Solicitante</th>
                <th>Partida Pago</th>
                <th>Tipo</th>
                <th>Estado</th>
                <th>Fecha</th>
                <th>Acciones</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="constancia in constancias" :key="`${constancia.axo}-${constancia.folio}`">
                <td>{{ constancia.axo }}</td>
                <td>{{ constancia.folio }}</td>
                <td>{{ constancia.id_licencia || 'N/A' }}</td>
                <td>{{ constancia.solicita }}</td>
                <td>{{ constancia.partidapago || 'N/A' }}</td>
                <td>
                  <span class="badge" :class="getTipoClass(constancia.tipo)">
                    {{ getTipoLabel(constancia.tipo) }}
                  </span>
                </td>
                <td>
                  <span class="badge" :class="constancia.vigente === 'V' ? 'badge-success' : 'badge-danger'">
                    {{ constancia.vigente === 'V' ? 'Vigente' : 'Cancelada' }}
                  </span>
                </td>
                <td>{{ formatDate(constancia.feccap) }}</td>
                <td>
                  <div class="action-buttons">
                    <button
                      class="btn-action btn-action-info"
                      @click="verDetalle(constancia)"
                      title="Ver detalle"
                    >
                      <font-awesome-icon icon="eye" />
                    </button>
                    <button
                      v-if="constancia.vigente === 'V'"
                      class="btn-action btn-action-warning"
                      @click="editarConstancia(constancia)"
                      title="Editar"
                    >
                      <font-awesome-icon icon="edit" />
                    </button>
                    <button
                      v-if="constancia.vigente === 'V'"
                      class="btn-action btn-action-danger"
                      @click="cancelarConstancia(constancia)"
                      title="Cancelar"
                    >
                      <font-awesome-icon icon="ban" />
                    </button>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>

        <!-- Paginación -->
        <div v-if="totalPages > 1" class="pagination-container">
          <button
            class="btn-municipal-secondary"
            @click="changePage(currentPage - 1)"
            :disabled="currentPage === 1 || loading"
          >
            <font-awesome-icon icon="chevron-left" /> Anterior
          </button>
          <span class="pagination-info">
            Página {{ currentPage }} de {{ totalPages }} ({{ totalRecords }} registros)
          </span>
          <button
            class="btn-municipal-secondary"
            @click="changePage(currentPage + 1)"
            :disabled="currentPage === totalPages || loading"
          >
            Siguiente <font-awesome-icon icon="chevron-right" />
          </button>
        </div>
      </div>
    </div>

    <!-- Mensaje cuando no hay resultados -->
    <div v-else-if="!loading" class="municipal-card">
      <div class="municipal-card-body text-center">
        <font-awesome-icon icon="info-circle" size="3x" class="text-muted mb-3" />
        <p class="text-muted">No se encontraron constancias. Utilice los filtros de búsqueda.</p>
      </div>
    </div>

    <!-- Loading spinner -->
    <div v-if="loading" class="text-center py-4">
      <div class="spinner-border text-primary" role="status">
        <span class="visually-hidden">Cargando...</span>
      </div>
    </div>

    </div>

    <!-- Modal de Detalle -->
    <Modal
      :show="showDetailModal"
      title="Detalle de Constancia"
      @close="showDetailModal = false"
      size="lg"
    >
      <div v-if="selectedConstancia" class="detail-grid">
        <div class="detail-item">
          <label>Año:</label>
          <span>{{ selectedConstancia.axo }}</span>
        </div>
        <div class="detail-item">
          <label>Folio:</label>
          <span>{{ selectedConstancia.folio }}</span>
        </div>
        <div class="detail-item">
          <label>Licencia:</label>
          <span>{{ selectedConstancia.id_licencia || 'N/A' }}</span>
        </div>
        <div class="detail-item">
          <label>Solicitante:</label>
          <span>{{ selectedConstancia.solicita }}</span>
        </div>
        <div class="detail-item">
          <label>Partida de Pago:</label>
          <span>{{ selectedConstancia.partidapago || 'N/A' }}</span>
        </div>
        <div class="detail-item">
          <label>Domicilio:</label>
          <span>{{ selectedConstancia.domicilio || 'N/A' }}</span>
        </div>
        <div class="detail-item">
          <label>Tipo:</label>
          <span class="badge" :class="getTipoClass(selectedConstancia.tipo)">
            {{ getTipoLabel(selectedConstancia.tipo) }}
          </span>
        </div>
        <div class="detail-item">
          <label>Estado:</label>
          <span class="badge" :class="selectedConstancia.vigente === 'V' ? 'badge-success' : 'badge-danger'">
            {{ selectedConstancia.vigente === 'V' ? 'Vigente' : 'Cancelada' }}
          </span>
        </div>
        <div class="detail-item">
          <label>Fecha de Captura:</label>
          <span>{{ formatDate(selectedConstancia.feccap) }}</span>
        </div>
        <div class="detail-item">
          <label>Capturista:</label>
          <span>{{ selectedConstancia.capturista }}</span>
        </div>
        <div class="detail-item full-width">
          <label>Observaciones:</label>
          <span>{{ selectedConstancia.observacion || 'Sin observaciones' }}</span>
        </div>
      </div>
      <template #footer>
        <button class="btn-municipal-secondary" @click="showDetailModal = false">
          Cerrar
        </button>
      </template>
    </Modal>

    <!-- Modal de Crear/Editar -->
    <Modal
      :show="showFormModal"
      :title="isEditing ? 'Editar Constancia' : 'Nueva Constancia'"
      @close="showFormModal = false"
      size="lg"
    >
      <form @submit.prevent="isEditing ? updateConstancia() : createConstancia()">
        <div class="form-grid">
          <div class="form-group">
            <label class="municipal-form-label required">Número de Licencia:</label>
            <input
              type="number"
              class="municipal-form-control"
              v-model="formData.id_licencia"
              required
            />
          </div>

          <div class="form-group">
            <label class="municipal-form-label required">Solicitante:</label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="formData.solicita"
              required
              maxlength="50"
            />
          </div>

          <div class="form-group">
            <label class="municipal-form-label required">Partida de Pago:</label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="formData.partidapago"
              required
              maxlength="25"
            />
          </div>

          <div class="form-group">
            <label class="municipal-form-label">Tipo de Constancia:</label>
            <select class="municipal-form-control" v-model="formData.tipo">
              <option :value="0">Regular</option>
              <option :value="1">Especial Tipo 1</option>
              <option :value="2">Especial Tipo 2</option>
              <option :value="3">Especial Tipo 3</option>
            </select>
          </div>

          <div class="form-group full-width">
            <label class="municipal-form-label">Domicilio:</label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="formData.domicilio"
              maxlength="65"
            />
          </div>

          <div class="form-group full-width">
            <label class="municipal-form-label">Observaciones:</label>
            <textarea
              class="municipal-form-control"
              v-model="formData.observacion"
              rows="3"
              maxlength="100"
            ></textarea>
          </div>
        </div>
      </form>
      <template #footer>
        <button class="btn-municipal-secondary" @click="showFormModal = false" :disabled="saving">
          Cancelar
        </button>
        <button
          class="btn-municipal-primary"
          @click="isEditing ? updateConstancia() : createConstancia()"
          :disabled="saving"
        >
          <span v-if="saving" class="spinner-border spinner-border-sm me-2"></span>
          {{ isEditing ? 'Actualizar' : 'Guardar' }}
        </button>
      </template>
    </Modal>
  </div>

    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showDocumentation"
      :componentName="'constanciafrm'"
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

const { execute, loading } = useApi()

// Estado
const constancias = ref([])
const selectedConstancia = ref(null)
const showDetailModal = ref(false)
const showFormModal = ref(false)
const isEditing = ref(false)
const saving = ref(false)

// Paginación
const currentPage = ref(1)
const pageSize = ref(10)
const totalRecords = ref(0)

// Búsqueda
const searchForm = ref({
  licencia: '',
  solicita: '',
  partidapago: ''
})

const lastSearchType = ref(null)
const lastSearchValue = ref(null)

// Formulario
const formData = ref({
  axo: null,
  folio: null,
  id_licencia: null,
  solicita: '',
  partidapago: '',
  domicilio: '',
  tipo: 0,
  observacion: ''
})

// Computed
const totalPages = computed(() => Math.ceil(totalRecords.value / pageSize.value))

// Métodos de búsqueda
const buscarPor = async (tipo) => {
  let searchField = tipo
  let searchValue = ''

  if (tipo === 'licencia') {
    if (!searchForm.value.licencia) return
    searchValue = searchForm.value.licencia
  } else if (tipo === 'solicita') {
    if (!searchForm.value.solicita) return
    searchValue = searchForm.value.solicita
  } else if (tipo === 'partidapago') {
    if (!searchForm.value.partidapago) return
    searchValue = searchForm.value.partidapago
  }

  lastSearchType.value = searchField
  lastSearchValue.value = searchValue
  currentPage.value = 1

  await loadConstancias()
}

const loadAll = async () => {
  lastSearchType.value = null
  lastSearchValue.value = null
  currentPage.value = 1
  searchForm.value = {
    licencia: '',
    solicita: '',
    partidapago: ''
  }
  await loadConstancias()
}

const loadConstancias = async () => {
  const result = await execute(
    'sp_constancias_list',
    'padron_licencias',
    [
      { nombre: 'p_page', valor: currentPage.value, tipo: 'integer' },
      { nombre: 'p_page_size', valor: pageSize.value, tipo: 'integer' },
      { nombre: 'p_search_field', valor: lastSearchType.value, tipo: 'string' },
      { nombre: 'p_search_value', valor: lastSearchValue.value, tipo: 'string' },
      { nombre: 'p_order_by', valor: 'axo_desc', tipo: 'string' }
    ],
    'guadalajara'
  )

  if (result && result.result && result.result.length > 0) {
    constancias.value = result.result
    totalRecords.value = parseInt(result.result[0].total_count)
  } else {
    constancias.value = []
    totalRecords.value = 0
  }
}

const changePage = (page) => {
  if (page >= 1 && page <= totalPages.value) {
    currentPage.value = page
    loadConstancias()
  }
}

// Métodos de detalle
const verDetalle = async (constancia) => {
  const result = await execute(
    'sp_constancias_get',
    'padron_licencias',
    [
      { nombre: 'p_axo', valor: constancia.axo, tipo: 'integer' },
      { nombre: 'p_folio', valor: constancia.folio, tipo: 'integer' }
    ],
    'guadalajara'
  )

  if (result && result.result && result.result.length > 0) {
    selectedConstancia.value = result.result[0]
    showDetailModal.value = true
  }
}

// Métodos CRUD
const openCreateModal = () => {
  isEditing.value = false
  formData.value = {
    axo: null,
    folio: null,
    id_licencia: null,
    solicita: '',
    partidapago: '',
    domicilio: '',
    tipo: 0,
    observacion: ''
  }
  showFormModal.value = true
}

const editarConstancia = async (constancia) => {
  const result = await execute(
    'sp_constancias_get',
    'padron_licencias',
    [
      { nombre: 'p_axo', valor: constancia.axo, tipo: 'integer' },
      { nombre: 'p_folio', valor: constancia.folio, tipo: 'integer' }
    ],
    'guadalajara'
  )

  if (result && result.result && result.result.length > 0) {
    const data = result.result[0]
    isEditing.value = true
    formData.value = {
      axo: data.axo,
      folio: data.folio,
      id_licencia: data.id_licencia,
      solicita: data.solicita,
      partidapago: data.partidapago,
      domicilio: data.domicilio || '',
      tipo: data.tipo,
      observacion: data.observacion || ''
    }
    showFormModal.value = true
  }
}

const createConstancia = async () => {
  const confirmResult = await Swal.fire({
    title: '¿Confirmar creación?',
    text: '¿Desea crear esta constancia?',
    icon: 'question',
    showCancelButton: true,
    confirmButtonText: 'Sí, crear',
    cancelButtonText: 'Cancelar',
    confirmButtonColor: '#ea8215',
    cancelButtonColor: '#6c757d'
  })

  if (!confirmResult.isConfirmed) return

  saving.value = true
  const result = await execute(
    'sp_constancias_create',
    'padron_licencias',
    [
      { nombre: 'p_id_licencia', valor: formData.value.id_licencia, tipo: 'integer' },
      { nombre: 'p_solicita', valor: formData.value.solicita, tipo: 'string' },
      { nombre: 'p_partidapago', valor: formData.value.partidapago, tipo: 'string' },
      { nombre: 'p_domicilio', valor: formData.value.domicilio, tipo: 'string' },
      { nombre: 'p_tipo', valor: formData.value.tipo, tipo: 'integer' },
      { nombre: 'p_observacion', valor: formData.value.observacion, tipo: 'string' }
    ],
    'guadalajara'
  )
  saving.value = false

  if (result && result.result && result.result.length > 0 && result.result[0].success) {
    await Swal.fire({
      title: '¡Éxito!',
      text: result.result[0].message,
      icon: 'success',
      confirmButtonColor: '#ea8215'
    })
    showFormModal.value = false
    await loadConstancias()
  } else {
    await Swal.fire({
      title: 'Error',
      text: result.result[0]?.message || 'No se pudo crear la constancia',
      icon: 'error',
      confirmButtonColor: '#ea8215'
    })
  }
}

const updateConstancia = async () => {
  const confirmResult = await Swal.fire({
    title: '¿Confirmar actualización?',
    text: '¿Desea actualizar esta constancia?',
    icon: 'question',
    showCancelButton: true,
    confirmButtonText: 'Sí, actualizar',
    cancelButtonText: 'Cancelar',
    confirmButtonColor: '#ea8215',
    cancelButtonColor: '#6c757d'
  })

  if (!confirmResult.isConfirmed) return

  saving.value = true
  const result = await execute(
    'sp_constancias_update',
    'padron_licencias',
    [
      { nombre: 'p_axo', valor: formData.value.axo, tipo: 'integer' },
      { nombre: 'p_folio', valor: formData.value.folio, tipo: 'integer' },
      { nombre: 'p_id_licencia', valor: formData.value.id_licencia, tipo: 'integer' },
      { nombre: 'p_solicita', valor: formData.value.solicita, tipo: 'string' },
      { nombre: 'p_partidapago', valor: formData.value.partidapago, tipo: 'string' },
      { nombre: 'p_domicilio', valor: formData.value.domicilio, tipo: 'string' },
      { nombre: 'p_tipo', valor: formData.value.tipo, tipo: 'integer' },
      { nombre: 'p_observacion', valor: formData.value.observacion, tipo: 'string' }
    ],
    'guadalajara'
  )
  saving.value = false

  if (result && result.result && result.result.length > 0 && result.result[0].success) {
    await Swal.fire({
      title: '¡Éxito!',
      text: result.result[0].message,
      icon: 'success',
      confirmButtonColor: '#ea8215'
    })
    showFormModal.value = false
    await loadConstancias()
  } else {
    await Swal.fire({
      title: 'Error',
      text: result.result[0]?.message || 'No se pudo actualizar la constancia',
      icon: 'error',
      confirmButtonColor: '#ea8215'
    })
  }
}

const cancelarConstancia = async (constancia) => {
  const confirmResult = await Swal.fire({
    title: '¿Cancelar constancia?',
    text: `¿Está seguro de cancelar la constancia ${constancia.axo}/${constancia.folio}?`,
    icon: 'warning',
    showCancelButton: true,
    confirmButtonText: 'Sí, cancelar',
    cancelButtonText: 'No',
    confirmButtonColor: '#dc3545',
    cancelButtonColor: '#6c757d'
  })

  if (!confirmResult.isConfirmed) return

  const result = await execute(
    'sp_constancias_cancel',
    'padron_licencias',
    [
      { nombre: 'p_axo', valor: constancia.axo, tipo: 'integer' },
      { nombre: 'p_folio', valor: constancia.folio, tipo: 'integer' }
    ],
    'guadalajara'
  )

  if (result && result.result && result.result.length > 0 && result.result[0].success) {
    await Swal.fire({
      title: '¡Éxito!',
      text: result.result[0].message,
      icon: 'success',
      confirmButtonColor: '#ea8215'
    })
    await loadConstancias()
  } else {
    await Swal.fire({
      title: 'Error',
      text: result.result[0]?.message || 'No se pudo cancelar la constancia',
      icon: 'error',
      confirmButtonColor: '#ea8215'
    })
  }
}

// Utilidades
const formatDate = (date) => {
  if (!date) return 'N/A'
  return new Date(date).toLocaleDateString('es-MX')
}

const getTipoLabel = (tipo) => {
  const tipos = {
    0: 'Regular',
    1: 'Especial Tipo 1',
    2: 'Especial Tipo 2',
    3: 'Especial Tipo 3'
  }
  return tipos[tipo] || 'Desconocido'
}

const getTipoClass = (tipo) => {
  const classes = {
    0: 'badge-primary',
    1: 'badge-info',
    2: 'badge-warning',
    3: 'badge-success'
  }
  return classes[tipo] || 'badge-secondary'
}
</script>

<style scoped>
.form-row {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 1rem;
  align-items: end;
}

.form-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 1rem;
}

.form-group.full-width {
  grid-column: 1 / -1;
}

.detail-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 1.5rem;
}

.detail-item {
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
}

.detail-item.full-width {
  grid-column: 1 / -1;
}

.detail-item label {
  font-weight: 600;
  color: var(--slate-600);
  font-size: 0.875rem;
}

.detail-item span {
  color: var(--slate-800);
}

.required::after {
  content: ' *';
  color: var(--danger);
}
</style>
