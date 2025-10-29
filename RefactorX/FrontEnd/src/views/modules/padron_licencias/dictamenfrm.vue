<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header" style="position: relative;">
      <div class="module-view-icon">
        <font-awesome-icon icon="clipboard-check" />
      </div>
      <div class="module-view-info">
        <h1>Gestión de Dictámenes</h1>
        <p>Padrón de Licencias - Administración de Dictámenes de Uso de Suelo</p></div>
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
          Nuevo Dictamen
        </button>
      </div>
    </div>

    <div class="module-view-content">

    <!-- Filtros de búsqueda -->
    <div class="municipal-card">
      <div class="municipal-card-body">
        <div class="form-row">
          <div class="form-group">
            <label class="municipal-form-label">Propietario:</label>
            <div class="input-group">
              <input
                type="text"
                class="municipal-form-control"
                v-model="searchForm.propietario"
                placeholder="Nombre del propietario"
                @keyup.enter="buscarPor('propietario')"
              />
              <button
                class="btn-municipal-primary"
                @click="buscarPor('propietario')"
                :disabled="!searchForm.propietario || loading"
              >
                <font-awesome-icon icon="search" /> Buscar
              </button>
            </div>
          </div>

          <div class="form-group">
            <label class="municipal-form-label">Domicilio:</label>
            <div class="input-group">
              <input
                type="text"
                class="municipal-form-control"
                v-model="searchForm.domicilio"
                placeholder="Domicilio del inmueble"
                @keyup.enter="buscarPor('domicilio')"
              />
              <button
                class="btn-municipal-primary"
                @click="buscarPor('domicilio')"
                :disabled="!searchForm.domicilio || loading"
              >
                <font-awesome-icon icon="search" /> Buscar
              </button>
            </div>
          </div>

          <div class="form-group">
            <label class="municipal-form-label">Actividad:</label>
            <div class="input-group">
              <input
                type="text"
                class="municipal-form-control"
                v-model="searchForm.actividad"
                placeholder="Actividad o giro"
                @keyup.enter="buscarPor('actividad')"
              />
              <button
                class="btn-municipal-primary"
                @click="buscarPor('actividad')"
                :disabled="!searchForm.actividad || loading"
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
              <font-awesome-icon icon="list" /> Ver Todos
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Resultados -->
    <div v-if="dictamenes.length > 0" class="municipal-card">
      <div class="municipal-card-header">
        <h5 class="municipal-card-title">
          <font-awesome-icon icon="list" />
          Dictámenes Encontrados ({{ totalRecords }} registros)
        </h5>
      </div>
      <div class="municipal-card-body">
        <div class="table-responsive">
          <table class="municipal-table table-hover">
            <thead>
              <tr>
                <th>ID</th>
                <th>Propietario</th>
                <th>Domicilio</th>
                <th>Actividad</th>
                <th>Área Útil (m²)</th>
                <th>Cajones</th>
                <th>Zona/Subzona</th>
                <th>Dictamen</th>
                <th>Fecha</th>
                <th>Acciones</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="dictamen in dictamenes" :key="dictamen.id_dictamen">
                <td>{{ dictamen.id_dictamen }}</td>
                <td>{{ dictamen.propietario }}</td>
                <td>{{ dictamen.domicilio }} {{ dictamen.no_exterior }}</td>
                <td>{{ dictamen.actividad }}</td>
                <td>{{ dictamen.area_util ? dictamen.area_util.toFixed(2) : '0.00' }}</td>
                <td>{{ dictamen.num_cajones || 0 }}</td>
                <td>{{ dictamen.zona }}/{{ dictamen.subzona }}</td>
                <td>
                  <span class="badge" :class="dictamen.dictamen === '1' ? 'badge-success' : 'badge-danger'">
                    {{ dictamen.dictamen === '1' ? 'APROBADO' : 'NEGADO' }}
                  </span>
                </td>
                <td>{{ formatDate(dictamen.fecha) }}</td>
                <td>
                  <div class="action-buttons">
                    <button
                      class="btn-action btn-action-info"
                      @click="verDetalle(dictamen)"
                      title="Ver detalle"
                    >
                      <font-awesome-icon icon="eye" />
                    </button>
                    <button
                      class="btn-action btn-action-warning"
                      @click="editarDictamen(dictamen)"
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
        <p class="text-muted">No se encontraron dictámenes. Utilice los filtros de búsqueda.</p>
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
      title="Detalle del Dictamen"
      @close="showDetailModal = false"
      size="lg"
    >
      <div v-if="selectedDictamen" class="detail-grid">
        <div class="detail-item">
          <label>ID Dictamen:</label>
          <span>{{ selectedDictamen.id_dictamen }}</span>
        </div>
        <div class="detail-item">
          <label>ID Giro:</label>
          <span>{{ selectedDictamen.id_giro || 'N/A' }}</span>
        </div>
        <div class="detail-item full-width">
          <label>Propietario:</label>
          <span>{{ selectedDictamen.propietario }}</span>
        </div>
        <div class="detail-item">
          <label>Domicilio:</label>
          <span>{{ selectedDictamen.domicilio }}</span>
        </div>
        <div class="detail-item">
          <label>No. Exterior:</label>
          <span>{{ selectedDictamen.no_exterior || 'N/A' }}</span>
        </div>
        <div class="detail-item">
          <label>No. Interior:</label>
          <span>{{ selectedDictamen.no_interior || 'N/A' }}</span>
        </div>
        <div class="detail-item">
          <label>Superficie Construida (m²):</label>
          <span>{{ selectedDictamen.supconst ? selectedDictamen.supconst.toFixed(2) : '0.00' }}</span>
        </div>
        <div class="detail-item">
          <label>Área Útil (m²):</label>
          <span>{{ selectedDictamen.area_util ? selectedDictamen.area_util.toFixed(2) : '0.00' }}</span>
        </div>
        <div class="detail-item">
          <label>Número de Cajones:</label>
          <span>{{ selectedDictamen.num_cajones || 0 }}</span>
        </div>
        <div class="detail-item full-width">
          <label>Actividad:</label>
          <span>{{ selectedDictamen.actividad }}</span>
        </div>
        <div class="detail-item full-width">
          <label>Uso de Suelo:</label>
          <span class="text-small">{{ selectedDictamen.uso_suelo || 'N/A' }}</span>
        </div>
        <div class="detail-item full-width">
          <label>Descripción de Uso:</label>
          <span>{{ selectedDictamen.desc_uso || 'N/A' }}</span>
        </div>
        <div class="detail-item">
          <label>Zona:</label>
          <span>{{ selectedDictamen.zona }}</span>
        </div>
        <div class="detail-item">
          <label>Subzona:</label>
          <span>{{ selectedDictamen.subzona }}</span>
        </div>
        <div class="detail-item">
          <label>Dictamen:</label>
          <span class="badge" :class="selectedDictamen.dictamen === '1' ? 'badge-success' : 'badge-danger'">
            {{ selectedDictamen.dictamen === '1' ? 'APROBADO' : 'NEGADO' }}
          </span>
        </div>
        <div class="detail-item">
          <label>Fecha:</label>
          <span>{{ formatDate(selectedDictamen.fecha) }}</span>
        </div>
        <div class="detail-item">
          <label>Capturista:</label>
          <span>{{ selectedDictamen.capturista }}</span>
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
      :title="isEditing ? 'Editar Dictamen' : 'Nuevo Dictamen'"
      @close="showFormModal = false"
      size="lg"
    >
      <form @submit.prevent="isEditing ? updateDictamen() : createDictamen()">
        <div class="form-grid">
          <div class="form-group">
            <label class="municipal-form-label required">ID Giro:</label>
            <input
              type="number"
              class="municipal-form-control"
              v-model.number="formData.id_giro"
              required
            />
          </div>

          <div class="form-group full-width">
            <label class="municipal-form-label required">Propietario:</label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="formData.propietario"
              required
              maxlength="100"
            />
          </div>

          <div class="form-group">
            <label class="municipal-form-label required">Domicilio:</label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="formData.domicilio"
              required
              maxlength="100"
            />
          </div>

          <div class="form-group">
            <label class="municipal-form-label">No. Exterior:</label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="formData.no_exterior"
              maxlength="5"
            />
          </div>

          <div class="form-group">
            <label class="municipal-form-label">No. Interior:</label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="formData.no_interior"
              maxlength="5"
            />
          </div>

          <div class="form-group">
            <label class="municipal-form-label">Superficie Construida (m²):</label>
            <input
              type="number"
              step="0.01"
              class="municipal-form-control"
              v-model.number="formData.supconst"
              min="0"
            />
          </div>

          <div class="form-group">
            <label class="municipal-form-label">Área Útil (m²):</label>
            <input
              type="number"
              step="0.01"
              class="municipal-form-control"
              v-model.number="formData.area_util"
              min="0"
            />
          </div>

          <div class="form-group">
            <label class="municipal-form-label">Número de Cajones:</label>
            <input
              type="number"
              class="municipal-form-control"
              v-model.number="formData.num_cajones"
              min="0"
            />
          </div>

          <div class="form-group full-width">
            <label class="municipal-form-label required">Actividad:</label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="formData.actividad"
              required
              maxlength="100"
            />
          </div>

          <div class="form-group full-width">
            <label class="municipal-form-label">Uso de Suelo:</label>
            <textarea
              class="municipal-form-control"
              v-model="formData.uso_suelo"
              rows="2"
              maxlength="200"
            ></textarea>
          </div>

          <div class="form-group full-width">
            <label class="municipal-form-label">Descripción de Uso:</label>
            <textarea
              class="municipal-form-control"
              v-model="formData.desc_uso"
              rows="2"
              maxlength="120"
            ></textarea>
          </div>

          <div class="form-group">
            <label class="municipal-form-label required">Zona:</label>
            <input
              type="number"
              class="municipal-form-control"
              v-model.number="formData.zona"
              required
              min="0"
            />
          </div>

          <div class="form-group">
            <label class="municipal-form-label required">Subzona:</label>
            <input
              type="number"
              class="municipal-form-control"
              v-model.number="formData.subzona"
              required
              min="0"
            />
          </div>

          <div class="form-group full-width">
            <label class="municipal-form-label required">Dictamen:</label>
            <select class="municipal-form-control" v-model="formData.dictamen" required>
              <option value="0">NEGADO</option>
              <option value="1">APROBADO</option>
            </select>
          </div>
        </div>
      </form>
      <template #footer>
        <button class="btn-municipal-secondary" @click="showFormModal = false" :disabled="saving">
          Cancelar
        </button>
        <button
          class="btn-municipal-primary"
          @click="isEditing ? updateDictamen() : createDictamen()"
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
      :componentName="'dictamenfrm'"
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
const dictamenes = ref([])
const selectedDictamen = ref(null)
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
  propietario: '',
  domicilio: '',
  actividad: ''
})

const lastSearchType = ref(null)
const lastSearchValue = ref(null)

// Formulario
const formData = ref({
  id_dictamen: null,
  id_giro: 0,
  propietario: '',
  domicilio: '',
  no_exterior: '',
  no_interior: '',
  supconst: 0,
  area_util: 0,
  num_cajones: 0,
  actividad: '',
  uso_suelo: '',
  desc_uso: '',
  zona: 0,
  subzona: 0,
  dictamen: '0'
})

// Computed
const totalPages = computed(() => Math.ceil(totalRecords.value / pageSize.value))

// Métodos de búsqueda
const buscarPor = async (tipo) => {
  let searchField = tipo
  let searchValue = ''

  if (tipo === 'propietario') {
    if (!searchForm.value.propietario) return
    searchValue = searchForm.value.propietario
  } else if (tipo === 'domicilio') {
    if (!searchForm.value.domicilio) return
    searchValue = searchForm.value.domicilio
  } else if (tipo === 'actividad') {
    if (!searchForm.value.actividad) return
    searchValue = searchForm.value.actividad
  }

  lastSearchType.value = searchField
  lastSearchValue.value = searchValue
  currentPage.value = 1

  await loadDictamenes()
}

const loadAll = async () => {
  lastSearchType.value = null
  lastSearchValue.value = null
  currentPage.value = 1
  searchForm.value = {
    propietario: '',
    domicilio: '',
    actividad: ''
  }
  await loadDictamenes()
}

const loadDictamenes = async () => {
  const result = await execute(
    'sp_dictamenes_list',
    'padron_licencias',
    [
      { nombre: 'p_page', valor: currentPage.value, tipo: 'integer' },
      { nombre: 'p_page_size', valor: pageSize.value, tipo: 'integer' },
      { nombre: 'p_search_field', valor: lastSearchType.value, tipo: 'string' },
      { nombre: 'p_search_value', valor: lastSearchValue.value, tipo: 'string' },
      { nombre: 'p_order_by', valor: 'id_desc', tipo: 'string' }
    ],
    'guadalajara'
  )

  if (result && result.result && result.result.length > 0) {
    dictamenes.value = result.result
    totalRecords.value = parseInt(result.result[0].total_count)
  } else {
    dictamenes.value = []
    totalRecords.value = 0
  }
}

const changePage = (page) => {
  if (page >= 1 && page <= totalPages.value) {
    currentPage.value = page
    loadDictamenes()
  }
}

// Métodos de detalle
const verDetalle = async (dictamen) => {
  const result = await execute(
    'sp_dictamenes_get',
    'padron_licencias',
    [
      { nombre: 'p_id_dictamen', valor: dictamen.id_dictamen, tipo: 'integer' }
    ],
    'guadalajara'
  )

  if (result && result.result && result.result.length > 0) {
    selectedDictamen.value = result.result[0]
    showDetailModal.value = true
  }
}

// Métodos CRUD
const openCreateModal = () => {
  isEditing.value = false
  formData.value = {
    id_dictamen: null,
    id_giro: 0,
    propietario: '',
    domicilio: '',
    no_exterior: '',
    no_interior: '',
    supconst: 0,
    area_util: 0,
    num_cajones: 0,
    actividad: '',
    uso_suelo: '',
    desc_uso: '',
    zona: 0,
    subzona: 0,
    dictamen: '0'
  }
  showFormModal.value = true
}

const editarDictamen = async (dictamen) => {
  const result = await execute(
    'sp_dictamenes_get',
    'padron_licencias',
    [
      { nombre: 'p_id_dictamen', valor: dictamen.id_dictamen, tipo: 'integer' }
    ],
    'guadalajara'
  )

  if (result && result.result && result.result.length > 0) {
    const data = result.result[0]
    isEditing.value = true
    formData.value = {
      id_dictamen: data.id_dictamen,
      id_giro: data.id_giro || 0,
      propietario: data.propietario,
      domicilio: data.domicilio,
      no_exterior: data.no_exterior || '',
      no_interior: data.no_interior || '',
      supconst: data.supconst || 0,
      area_util: data.area_util || 0,
      num_cajones: data.num_cajones || 0,
      actividad: data.actividad,
      uso_suelo: data.uso_suelo || '',
      desc_uso: data.desc_uso || '',
      zona: data.zona,
      subzona: data.subzona,
      dictamen: data.dictamen
    }
    showFormModal.value = true
  }
}

const createDictamen = async () => {
  const confirmResult = await Swal.fire({
    title: '¿Confirmar creación?',
    text: '¿Desea crear este dictamen?',
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
    'sp_dictamenes_create',
    'padron_licencias',
    [
      { nombre: 'p_id_giro', valor: formData.value.id_giro, tipo: 'integer' },
      { nombre: 'p_propietario', valor: formData.value.propietario, tipo: 'string' },
      { nombre: 'p_domicilio', valor: formData.value.domicilio, tipo: 'string' },
      { nombre: 'p_no_exterior', valor: formData.value.no_exterior, tipo: 'string' },
      { nombre: 'p_no_interior', valor: formData.value.no_interior, tipo: 'string' },
      { nombre: 'p_supconst', valor: formData.value.supconst, tipo: 'double precision' },
      { nombre: 'p_area_util', valor: formData.value.area_util, tipo: 'double precision' },
      { nombre: 'p_num_cajones', valor: formData.value.num_cajones, tipo: 'integer' },
      { nombre: 'p_actividad', valor: formData.value.actividad, tipo: 'string' },
      { nombre: 'p_uso_suelo', valor: formData.value.uso_suelo, tipo: 'string' },
      { nombre: 'p_desc_uso', valor: formData.value.desc_uso, tipo: 'string' },
      { nombre: 'p_zona', valor: formData.value.zona, tipo: 'integer' },
      { nombre: 'p_subzona', valor: formData.value.subzona, tipo: 'integer' },
      { nombre: 'p_dictamen', valor: formData.value.dictamen, tipo: 'string' }
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
    await loadDictamenes()
  } else {
    await Swal.fire({
      title: 'Error',
      text: result.result[0]?.message || 'No se pudo crear el dictamen',
      icon: 'error',
      confirmButtonColor: '#ea8215'
    })
  }
}

const updateDictamen = async () => {
  const confirmResult = await Swal.fire({
    title: '¿Confirmar actualización?',
    text: '¿Desea actualizar este dictamen?',
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
    'sp_dictamenes_update',
    'padron_licencias',
    [
      { nombre: 'p_id_dictamen', valor: formData.value.id_dictamen, tipo: 'integer' },
      { nombre: 'p_id_giro', valor: formData.value.id_giro, tipo: 'integer' },
      { nombre: 'p_propietario', valor: formData.value.propietario, tipo: 'string' },
      { nombre: 'p_domicilio', valor: formData.value.domicilio, tipo: 'string' },
      { nombre: 'p_no_exterior', valor: formData.value.no_exterior, tipo: 'string' },
      { nombre: 'p_no_interior', valor: formData.value.no_interior, tipo: 'string' },
      { nombre: 'p_supconst', valor: formData.value.supconst, tipo: 'double precision' },
      { nombre: 'p_area_util', valor: formData.value.area_util, tipo: 'double precision' },
      { nombre: 'p_num_cajones', valor: formData.value.num_cajones, tipo: 'integer' },
      { nombre: 'p_actividad', valor: formData.value.actividad, tipo: 'string' },
      { nombre: 'p_uso_suelo', valor: formData.value.uso_suelo, tipo: 'string' },
      { nombre: 'p_desc_uso', valor: formData.value.desc_uso, tipo: 'string' },
      { nombre: 'p_zona', valor: formData.value.zona, tipo: 'integer' },
      { nombre: 'p_subzona', valor: formData.value.subzona, tipo: 'integer' },
      { nombre: 'p_dictamen', valor: formData.value.dictamen, tipo: 'string' }
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
    await loadDictamenes()
  } else {
    await Swal.fire({
      title: 'Error',
      text: result.result[0]?.message || 'No se pudo actualizar el dictamen',
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

.text-small {
  font-size: 0.875rem;
  line-height: 1.4;
}

.required::after {
  content: ' *';
  color: var(--danger);
}
</style>
