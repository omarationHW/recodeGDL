<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="clipboard-check" />
      </div>
      <div class="module-view-info">
        <h1>Gestión de Dictámenes</h1>
        <p>Padrón de Licencias - Administración de Dictámenes de Uso de Suelo</p>
      </div>
      <div class="button-group ms-auto">
        <button
          class="btn-municipal-primary"
          @click="buscar"
          :disabled="loading"
        >
          <font-awesome-icon icon="sync-alt" />
          Actualizar
        </button>
        <button
          class="btn-municipal-purple"
          @click="openDocumentation"
        >
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <!-- Stats Cards con skeleton loading -->
      <div class="stats-grid stats-grid-4" v-if="loadingStats">
        <div class="stat-card stat-card-loading" v-for="n in 4" :key="`loading-${n}`">
          <div class="stat-content">
            <div class="skeleton-icon"></div>
            <div class="skeleton-number"></div>
            <div class="skeleton-label"></div>
            <div class="skeleton-percentage"></div>
          </div>
        </div>
      </div>

      <!-- Stats Cards con datos -->
      <div class="stats-grid stats-grid-4" v-else-if="estadisticas">
        <div class="stat-card stat-total">
          <div class="stat-content">
            <div class="stat-icon">
              <font-awesome-icon icon="clipboard-check" />
            </div>
            <h3 class="stat-number">{{ formatNumber(estadisticas.total_dictamenes) }}</h3>
            <p class="stat-label">Total Dictámenes</p>
          </div>
        </div>

        <div class="stat-card stat-vigente">
          <div class="stat-content">
            <div class="stat-icon">
              <font-awesome-icon icon="check-circle" />
            </div>
            <h3 class="stat-number">{{ formatNumber(estadisticas.dictamenes_aprobados) }}</h3>
            <p class="stat-label">Aprobados</p>
            <small class="stat-percentage">
              {{ calculatePercentage(estadisticas.dictamenes_aprobados, estadisticas.total_dictamenes) }}%
            </small>
          </div>
        </div>

        <div class="stat-card stat-licencias">
          <div class="stat-content">
            <div class="stat-icon">
              <font-awesome-icon icon="times-circle" />
            </div>
            <h3 class="stat-number">{{ formatNumber(estadisticas.dictamenes_rechazados) }}</h3>
            <p class="stat-label">Rechazados</p>
            <small class="stat-percentage">
              {{ calculatePercentage(estadisticas.dictamenes_rechazados, estadisticas.total_dictamenes) }}%
            </small>
          </div>
        </div>

        <div class="stat-card stat-reglamentados">
          <div class="stat-content">
            <div class="stat-icon">
              <font-awesome-icon icon="ruler-combined" />
            </div>
            <h3 class="stat-number">{{ formatNumber(estadisticas.promedio_superficie, 2) }}</h3>
            <p class="stat-label">Promedio m² Construidos</p>
            <small class="stat-percentage">
              {{ formatNumber(estadisticas.promedio_area_util, 2) }} m² útiles
            </small>
          </div>
        </div>
      </div>

      <!-- Filtros de búsqueda -->
      <div class="municipal-card">
        <div class="municipal-card-header clickable-header" @click="toggleFilters">
          <h5>
            <font-awesome-icon icon="filter" />
            Filtros de Búsqueda
            <font-awesome-icon :icon="showFilters ? 'chevron-up' : 'chevron-down'" class="ms-2" />
          </h5>
        </div>

        <div v-show="showFilters" class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Propietario:</label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="searchForm.propietario"
                placeholder="Nombre del propietario"
                @keyup.enter="buscar"
              />
            </div>

            <div class="form-group">
              <label class="municipal-form-label">Domicilio:</label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="searchForm.domicilio"
                placeholder="Domicilio del inmueble"
                @keyup.enter="buscar"
              />
            </div>

            <div class="form-group">
              <label class="municipal-form-label">Actividad:</label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="searchForm.actividad"
                placeholder="Actividad o giro"
                @keyup.enter="buscar"
              />
            </div>

            <div class="form-group">
              <label class="municipal-form-label">&nbsp;</label>
              <div class="btn-group-actions">
                <button @click="buscar" class="btn-municipal-primary" :disabled="loading">
                  <font-awesome-icon icon="search" /> Buscar
                </button>
                <button @click="limpiarFiltros" class="btn-municipal-secondary" :disabled="loading">
                  <font-awesome-icon icon="eraser" /> Limpiar
                </button>
                <button @click="openCreateModal" class="btn-municipal-success" :disabled="loading">
                  <font-awesome-icon icon="plus" /> Nuevo
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Tabla de resultados -->
      <div class="municipal-card">
        <div class="municipal-card-header header-with-badge">
          <h5>
            <font-awesome-icon icon="list" />
            Listado de Dictámenes
          </h5>
          <span class="badge-purple" v-if="totalRecords > 0">
            {{ totalRecords.toLocaleString() }} registros
          </span>
        </div>
        <div class="municipal-card-body p-0">
          <div class="table-responsive">
            <table class="table table-hover mb-0">
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
                  <th width="120">Acciones</th>
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
                <tr v-else-if="dictamenes.length === 0">
                  <td colspan="10" class="empty-state">
                    <div class="empty-state-content">
                      <font-awesome-icon icon="inbox" class="empty-state-icon" />
                      <p class="empty-state-text">No se encontraron dictámenes</p>
                      <p class="empty-state-hint">Intenta ajustar los filtros de búsqueda o presiona "Actualizar"</p>
                    </div>
                  </td>
                </tr>
                <tr v-else v-for="dictamen in dictamenes" :key="dictamen.id_dictamen" class="clickable-row">
                  <td>
                    <span class="badge bg-secondary">{{ dictamen.id_dictamen }}</span>
                  </td>
                  <td class="text-truncate" style="max-width: 200px">{{ trimString(dictamen.propietario) }}</td>
                  <td class="text-truncate" style="max-width: 200px">
                    {{ trimString(dictamen.domicilio) }} {{ trimString(dictamen.no_exterior) }}
                  </td>
                  <td class="text-truncate" style="max-width: 200px">{{ trimString(dictamen.actividad) }}</td>
                  <td class="text-end">{{ dictamen.area_util ? dictamen.area_util.toFixed(2) : '0.00' }}</td>
                  <td class="text-center">{{ dictamen.num_cajones || 0 }}</td>
                  <td class="text-center">{{ dictamen.zona }}/{{ dictamen.subzona }}</td>
                  <td>
                    <span class="badge" :class="getDictamenBadgeClass(dictamen.dictamen)">
                      {{ getDictamenText(dictamen.dictamen) }}
                    </span>
                  </td>
                  <td>{{ formatDate(dictamen.fecha) }}</td>
                  <td>
                    <div class="btn-group-actions">
                      <button
                        @click="verDetalle(dictamen)"
                        class="btn-table btn-table-info"
                        title="Ver detalle"
                      >
                        <font-awesome-icon icon="eye" />
                      </button>
                      <button
                        @click="editarDictamen(dictamen)"
                        class="btn-table btn-table-primary"
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
              Página {{ currentPage }} de {{ totalPages }} ({{ totalRecords.toLocaleString() }} registros)
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
    </div>

    <!-- Modal de Detalle -->
    <Modal
      :show="showDetailModal"
      @close="showDetailModal = false"
      size="xl"
    >
      <template #header>
        <h5 class="modal-title">
          <font-awesome-icon icon="eye" class="me-2 text-info" />
          Detalle del Dictamen
        </h5>
      </template>

      <div v-if="selectedDictamen" class="dictamen-detail-content">
        <!-- Sección: Información General -->
        <div class="modal-section">
          <div class="section-header">
            <font-awesome-icon icon="info-circle" class="section-icon" />
            <h6 class="section-title">Información General</h6>
          </div>
          <div class="modal-grid-3">
            <div class="detail-item">
              <label>ID Dictamen:</label>
              <span>{{ selectedDictamen.id_dictamen }}</span>
            </div>
            <div class="detail-item">
              <label>ID Giro:</label>
              <span>{{ selectedDictamen.id_giro || 'N/A' }}</span>
            </div>
            <div class="detail-item">
              <label>Capturista:</label>
              <span>{{ trimString(selectedDictamen.capturista) }}</span>
            </div>
          </div>
        </div>

        <!-- Sección: Propietario y Ubicación -->
        <div class="modal-section">
          <div class="section-header">
            <font-awesome-icon icon="user" class="section-icon" />
            <h6 class="section-title">Propietario y Ubicación</h6>
          </div>
          <div class="modal-grid-2">
            <div class="detail-item full-width">
              <label>Propietario:</label>
              <span>{{ trimString(selectedDictamen.propietario) }}</span>
            </div>
            <div class="detail-item">
              <label>Domicilio:</label>
              <span>{{ trimString(selectedDictamen.domicilio) }}</span>
            </div>
            <div class="detail-item">
              <label>No. Exterior:</label>
              <span>{{ trimString(selectedDictamen.no_exterior) || 'N/A' }}</span>
            </div>
            <div class="detail-item">
              <label>No. Interior:</label>
              <span>{{ trimString(selectedDictamen.no_interior) || 'N/A' }}</span>
            </div>
          </div>
        </div>

        <!-- Sección: Características del Inmueble -->
        <div class="modal-section">
          <div class="section-header">
            <font-awesome-icon icon="building" class="section-icon" />
            <h6 class="section-title">Características del Inmueble</h6>
          </div>
          <div class="modal-grid-3">
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
          </div>
        </div>

        <!-- Sección: Actividad y Uso de Suelo -->
        <div class="modal-section">
          <div class="section-header">
            <font-awesome-icon icon="briefcase" class="section-icon" />
            <h6 class="section-title">Actividad y Uso de Suelo</h6>
          </div>
          <div class="modal-grid-1">
            <div class="detail-item">
              <label>Actividad:</label>
              <span>{{ trimString(selectedDictamen.actividad) }}</span>
            </div>
            <div class="detail-item">
              <label>Uso de Suelo:</label>
              <span class="text-small">{{ trimString(selectedDictamen.uso_suelo) || 'N/A' }}</span>
            </div>
            <div class="detail-item">
              <label>Descripción de Uso:</label>
              <span>{{ trimString(selectedDictamen.desc_uso) || 'N/A' }}</span>
            </div>
          </div>
        </div>

        <!-- Sección: Dictamen Final -->
        <div class="modal-section">
          <div class="section-header">
            <font-awesome-icon icon="gavel" class="section-icon" />
            <h6 class="section-title">Dictamen Final</h6>
          </div>
          <div class="modal-grid-4">
            <div class="detail-item">
              <label>Zona:</label>
              <span>{{ selectedDictamen.zona }}</span>
            </div>
            <div class="detail-item">
              <label>Subzona:</label>
              <span>{{ selectedDictamen.subzona }}</span>
            </div>
            <div class="detail-item">
              <label>Resultado:</label>
              <span class="badge" :class="getDictamenBadgeClass(selectedDictamen.dictamen)">
                {{ getDictamenText(selectedDictamen.dictamen) }}
              </span>
            </div>
            <div class="detail-item">
              <label>Fecha:</label>
              <span>{{ formatDate(selectedDictamen.fecha) }}</span>
            </div>
          </div>
        </div>
      </div>

      <template #footer>
        <button class="btn-municipal-secondary" @click="showDetailModal = false">
          <font-awesome-icon icon="times" /> Cerrar
        </button>
      </template>
    </Modal>

    <!-- Modal de Crear/Editar -->
    <Modal
      :show="showFormModal"
      @close="closeFormModal"
      size="xl"
    >
      <template #header>
        <h5 class="modal-title">
          <font-awesome-icon
            :icon="isEditing ? 'edit' : 'plus-circle'"
            class="me-2"
            :class="isEditing ? 'text-warning' : 'text-success'"
          />
          {{ isEditing ? 'Editar Dictamen' : 'Nuevo Dictamen' }}
        </h5>
      </template>

      <form @submit.prevent="isEditing ? updateDictamen() : createDictamen()">
        <div class="dictamen-form-content">
          <!-- Sección: Información del Propietario -->
          <div class="modal-section">
            <div class="section-header">
              <font-awesome-icon icon="user" class="section-icon" />
              <h6 class="section-title">Información del Propietario</h6>
            </div>
            <div class="modal-grid-2">
              <div class="form-group full-width">
                <label class="form-label-modal">
                  <font-awesome-icon icon="user" class="label-icon" />
                  Propietario <span class="text-danger">*</span>
                </label>
                <input
                  type="text"
                  class="form-input-modal"
                  v-model="formData.propietario"
                  required
                  maxlength="100"
                  placeholder="Nombre completo del propietario"
                />
              </div>

              <div class="form-group">
                <label class="form-label-modal">
                  <font-awesome-icon icon="map-marker-alt" class="label-icon" />
                  Domicilio <span class="text-danger">*</span>
                </label>
                <input
                  type="text"
                  class="form-input-modal"
                  v-model="formData.domicilio"
                  required
                  maxlength="100"
                  placeholder="Calle y número"
                />
              </div>

              <div class="form-group">
                <label class="form-label-modal">
                  <font-awesome-icon icon="hashtag" class="label-icon" />
                  No. Exterior
                </label>
                <input
                  type="text"
                  class="form-input-modal"
                  v-model="formData.no_exterior"
                  maxlength="5"
                  placeholder="Ej: 123"
                />
              </div>

              <div class="form-group">
                <label class="form-label-modal">
                  <font-awesome-icon icon="hashtag" class="label-icon" />
                  No. Interior
                </label>
                <input
                  type="text"
                  class="form-input-modal"
                  v-model="formData.no_interior"
                  maxlength="5"
                  placeholder="Ej: A, B-1"
                />
              </div>
            </div>
          </div>

          <!-- Sección: Características del Inmueble -->
          <div class="modal-section">
            <div class="section-header">
              <font-awesome-icon icon="building" class="section-icon" />
              <h6 class="section-title">Características del Inmueble</h6>
            </div>
            <div class="modal-grid-3">
              <div class="form-group">
                <label class="form-label-modal">
                  <font-awesome-icon icon="ruler-combined" class="label-icon" />
                  Superficie Construida (m²)
                </label>
                <input
                  type="number"
                  step="0.01"
                  class="form-input-modal"
                  v-model.number="formData.supconst"
                  min="0"
                  placeholder="0.00"
                />
              </div>

              <div class="form-group">
                <label class="form-label-modal">
                  <font-awesome-icon icon="ruler" class="label-icon" />
                  Área Útil (m²)
                </label>
                <input
                  type="number"
                  step="0.01"
                  class="form-input-modal"
                  v-model.number="formData.area_util"
                  min="0"
                  placeholder="0.00"
                />
              </div>

              <div class="form-group">
                <label class="form-label-modal">
                  <font-awesome-icon icon="parking" class="label-icon" />
                  Número de Cajones
                </label>
                <input
                  type="number"
                  class="form-input-modal"
                  v-model.number="formData.num_cajones"
                  min="0"
                  placeholder="0"
                />
              </div>

              <div class="form-group">
                <label class="form-label-modal">
                  <font-awesome-icon icon="tags" class="label-icon" />
                  ID Giro <span class="text-danger">*</span>
                </label>
                <input
                  type="number"
                  class="form-input-modal"
                  v-model.number="formData.id_giro"
                  required
                  min="0"
                />
              </div>
            </div>
          </div>

          <!-- Sección: Actividad y Uso de Suelo -->
          <div class="modal-section">
            <div class="section-header">
              <font-awesome-icon icon="briefcase" class="section-icon" />
              <h6 class="section-title">Actividad y Uso de Suelo</h6>
            </div>
            <div class="modal-grid-1">
              <div class="form-group">
                <label class="form-label-modal">
                  <font-awesome-icon icon="briefcase" class="label-icon" />
                  Actividad <span class="text-danger">*</span>
                </label>
                <input
                  type="text"
                  class="form-input-modal"
                  v-model="formData.actividad"
                  required
                  maxlength="100"
                  placeholder="Descripción de la actividad comercial"
                />
              </div>

              <div class="form-group">
                <label class="form-label-modal">
                  <font-awesome-icon icon="map" class="label-icon" />
                  Uso de Suelo
                </label>
                <textarea
                  class="form-input-modal"
                  v-model="formData.uso_suelo"
                  rows="2"
                  maxlength="200"
                  placeholder="Uso de suelo permitido"
                ></textarea>
              </div>

              <div class="form-group">
                <label class="form-label-modal">
                  <font-awesome-icon icon="file-alt" class="label-icon" />
                  Descripción de Uso
                </label>
                <textarea
                  class="form-input-modal"
                  v-model="formData.desc_uso"
                  rows="2"
                  maxlength="120"
                  placeholder="Descripción adicional"
                ></textarea>
              </div>
            </div>
          </div>

          <!-- Sección: Ubicación y Dictamen -->
          <div class="modal-section">
            <div class="section-header">
              <font-awesome-icon icon="gavel" class="section-icon" />
              <h6 class="section-title">Ubicación y Dictamen</h6>
            </div>
            <div class="modal-grid-4">
              <div class="form-group">
                <label class="form-label-modal">
                  <font-awesome-icon icon="map-pin" class="label-icon" />
                  Zona <span class="text-danger">*</span>
                </label>
                <input
                  type="number"
                  class="form-input-modal"
                  v-model.number="formData.zona"
                  required
                  min="0"
                  placeholder="0"
                />
              </div>

              <div class="form-group">
                <label class="form-label-modal">
                  <font-awesome-icon icon="map-pin" class="label-icon" />
                  Subzona <span class="text-danger">*</span>
                </label>
                <input
                  type="number"
                  class="form-input-modal"
                  v-model.number="formData.subzona"
                  required
                  min="0"
                  placeholder="0"
                />
              </div>

              <div class="form-group span-2">
                <label class="form-label-modal">
                  <font-awesome-icon icon="check-circle" class="label-icon" />
                  Resultado del Dictamen <span class="text-danger">*</span>
                </label>
                <select class="form-select-modal" v-model="formData.dictamen" required>
                  <option value="0">❌ NEGADO</option>
                  <option value="1">✅ APROBADO</option>
                  <option value="2">⏳ EN PROCESO</option>
                  <option value="3">📋 PENDIENTE</option>
                </select>
              </div>
            </div>
          </div>
        </div>
      </form>

      <template #footer>
        <button class="btn-municipal-secondary" @click="closeFormModal" :disabled="saving">
          <font-awesome-icon icon="times" /> Cancelar
        </button>
        <button
          class="btn-municipal-primary"
          @click="isEditing ? updateDictamen() : createDictamen()"
          :disabled="saving"
        >
          <span v-if="saving" class="spinner-border spinner-border-sm me-2"></span>
          <font-awesome-icon v-else :icon="isEditing ? 'save' : 'plus-circle'" />
          {{ isEditing ? 'Actualizar' : 'Guardar' }}
        </button>
      </template>
    </Modal>

    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showDocumentation"
      :componentName="'dictamenfrm'"
      :moduleName="'padron_licencias'"
      @close="closeDocumentation"
    />
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import Modal from '@/components/common/Modal.vue'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import Swal from 'sweetalert2'

// Composables
const { execute, loading } = useApi()
const { handleApiError, showToast } = useLicenciasErrorHandler()
const { showLoading, hideLoading } = useGlobalLoading()

// Estado
const dictamenes = ref([])
const selectedDictamen = ref(null)
const showDetailModal = ref(false)
const showFormModal = ref(false)
const isEditing = ref(false)
const saving = ref(false)
const showDocumentation = ref(false)
const showFilters = ref(true)
const loadingStats = ref(true)

// Estadísticas
const estadisticas = ref(null)

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

// Lifecycle
onMounted(async () => {
  await cargarEstadisticas()
})

// Métodos de estadísticas
const cargarEstadisticas = async () => {
  loadingStats.value = true
  try {
    const startTime = performance.now()

    const response = await execute(
      'sp_dictamenes_estadisticas',
      'padron_licencias',
      [],
      '', null, 'comun'
    )

    const endTime = performance.now()
    const responseTime = Math.round(endTime - startTime)

    if (response && response.result && response.result.length > 0) {
      estadisticas.value = response.result[0]
      showToast('success', `Estadísticas cargadas en ${responseTime}ms`, responseTime)
    }
  } catch (error) {
    handleApiError(error, 'Error al cargar estadísticas')
  } finally {
    loadingStats.value = false
  }
}

// Métodos de búsqueda
const buscar = async () => {
  currentPage.value = 1
  await loadDictamenes()
}

const limpiarFiltros = async () => {
  searchForm.value = {
    propietario: '',
    domicilio: '',
    actividad: ''
  }
  currentPage.value = 1
  dictamenes.value = []
  totalRecords.value = 0
}

const loadDictamenes = async () => {
  try {
    const startTime = performance.now()

    const response = await execute(
      'sp_dictamenes_list',
      'padron_licencias',
      [
        { nombre: 'p_page', valor: currentPage.value, tipo: 'integer' },
        { nombre: 'p_page_size', valor: pageSize.value, tipo: 'integer' },
        { nombre: 'p_propietario', valor: searchForm.value.propietario || null, tipo: 'string' },
        { nombre: 'p_domicilio', valor: searchForm.value.domicilio || null, tipo: 'string' },
        { nombre: 'p_actividad', valor: searchForm.value.actividad || null, tipo: 'string' }
      ],
      '', null, 'comun'
    )

    const endTime = performance.now()
    const responseTime = Math.round(endTime - startTime)

    if (response && response.result && response.result.length > 0) {
      dictamenes.value = response.result
      totalRecords.value = parseInt(response.result[0].total_count)
      showToast('success', `${totalRecords.value} registros encontrados en ${responseTime}ms`, responseTime)
    } else {
      dictamenes.value = []
      totalRecords.value = 0
      showToast('info', 'No se encontraron registros')
    }
  } catch (error) {
    handleApiError(error, 'Error al buscar dictámenes')
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
  showLoading('Cargando detalle...', 'Obteniendo información del dictamen')
  try {
    const response = await execute(
      'sp_dictamenes_get',
      'padron_licencias',
      [
        { nombre: 'p_id_dictamen', valor: dictamen.id_dictamen, tipo: 'integer' }
      ],
      '', null, 'comun'
    )

    hideLoading()

    if (response && response.result && response.result.length > 0) {
      selectedDictamen.value = response.result[0]
      showDetailModal.value = true
    }
  } catch (error) {
    hideLoading()
    handleApiError(error, 'Error al obtener detalle del dictamen')
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
  showLoading('Cargando datos...', 'Preparando formulario de edición')
  try {
    const response = await execute(
      'sp_dictamenes_get',
      'padron_licencias',
      [
        { nombre: 'p_id_dictamen', valor: dictamen.id_dictamen, tipo: 'integer' }
      ],
      '', null, 'comun'
    )

    hideLoading()

    if (response && response.result && response.result.length > 0) {
      const data = response.result[0]
      isEditing.value = true
      formData.value = {
        id_dictamen: data.id_dictamen,
        id_giro: data.id_giro || 0,
        propietario: trimString(data.propietario),
        domicilio: trimString(data.domicilio),
        no_exterior: trimString(data.no_exterior) || '',
        no_interior: trimString(data.no_interior) || '',
        supconst: data.supconst || 0,
        area_util: data.area_util || 0,
        num_cajones: data.num_cajones || 0,
        actividad: trimString(data.actividad),
        uso_suelo: trimString(data.uso_suelo) || '',
        desc_uso: trimString(data.desc_uso) || '',
        zona: data.zona,
        subzona: data.subzona,
        dictamen: trimString(data.dictamen)
      }
      showFormModal.value = true
    }
  } catch (error) {
    hideLoading()
    handleApiError(error, 'Error al cargar datos del dictamen')
  }
}

const createDictamen = async () => {
  // Confirmación
  const result = await Swal.fire({
    icon: 'question',
    title: '¿Crear Nuevo Dictamen?',
    html: `
      <div style="text-align: left; padding: 1rem;">
        <p><strong>Propietario:</strong> ${formData.value.propietario}</p>
        <p><strong>Domicilio:</strong> ${formData.value.domicilio}</p>
        <p><strong>Actividad:</strong> ${formData.value.actividad}</p>
        <p><strong>Dictamen:</strong> ${getDictamenText(formData.value.dictamen)}</p>
      </div>
    `,
    showCancelButton: true,
    confirmButtonText: 'Sí, crear dictamen',
    confirmButtonColor: '#ea8215',
    cancelButtonText: 'Cancelar',
    cancelButtonColor: '#6c757d'
  })

  if (!result.isConfirmed) return

  saving.value = true
  try {
    const response = await execute(
      'sp_dictamenes_create',
      'padron_licencias',
      [
        { nombre: 'p_id_giro', valor: formData.value.id_giro, tipo: 'integer' },
        { nombre: 'p_propietario', valor: formData.value.propietario, tipo: 'string' },
        { nombre: 'p_domicilio', valor: formData.value.domicilio, tipo: 'string' },
        { nombre: 'p_actividad', valor: formData.value.actividad, tipo: 'string' },
        { nombre: 'p_no_exterior', valor: formData.value.no_exterior || null, tipo: 'string' },
        { nombre: 'p_no_interior', valor: formData.value.no_interior || null, tipo: 'string' },
        { nombre: 'p_supconst', valor: formData.value.supconst || null, tipo: 'double precision' },
        { nombre: 'p_area_util', valor: formData.value.area_util || null, tipo: 'double precision' },
        { nombre: 'p_num_cajones', valor: formData.value.num_cajones || 0, tipo: 'integer' },
        { nombre: 'p_uso_suelo', valor: formData.value.uso_suelo || null, tipo: 'string' },
        { nombre: 'p_desc_uso', valor: formData.value.desc_uso || null, tipo: 'string' },
        { nombre: 'p_zona', valor: formData.value.zona || null, tipo: 'integer' },
        { nombre: 'p_subzona', valor: formData.value.subzona || null, tipo: 'integer' },
        { nombre: 'p_dictamen', valor: formData.value.dictamen, tipo: 'string' }
      ],
      '', null, 'comun'
    )

    if (response && response.result && response.result[0]?.success) {
      await Swal.fire({
        title: '¡Éxito!',
        text: response.result[0].message,
        icon: 'success',
        confirmButtonColor: '#ea8215',
        timer: 3000,
        timerProgressBar: true
      })
      closeFormModal()
    } else {
      throw new Error(response.result[0]?.message || 'No se pudo crear el dictamen')
    }
  } catch (error) {
    handleApiError(error, 'Error al crear el dictamen')
  } finally {
    saving.value = false
  }
}

const updateDictamen = async () => {
  // Confirmación
  const result = await Swal.fire({
    icon: 'question',
    title: '¿Actualizar Dictamen?',
    html: `
      <div style="text-align: left; padding: 1rem;">
        <p><strong>ID:</strong> ${formData.value.id_dictamen}</p>
        <p><strong>Propietario:</strong> ${formData.value.propietario}</p>
        <p><strong>Domicilio:</strong> ${formData.value.domicilio}</p>
        <p><strong>Actividad:</strong> ${formData.value.actividad}</p>
        <p><strong>Dictamen:</strong> ${getDictamenText(formData.value.dictamen)}</p>
      </div>
    `,
    showCancelButton: true,
    confirmButtonText: 'Sí, actualizar',
    confirmButtonColor: '#ea8215',
    cancelButtonText: 'Cancelar',
    cancelButtonColor: '#6c757d'
  })

  if (!result.isConfirmed) return

  saving.value = true
  try {
    const response = await execute(
      'sp_dictamenes_update',
      'padron_licencias',
      [
        { nombre: 'p_id_dictamen', valor: formData.value.id_dictamen, tipo: 'integer' },
        { nombre: 'p_id_giro', valor: formData.value.id_giro, tipo: 'integer' },
        { nombre: 'p_propietario', valor: formData.value.propietario, tipo: 'string' },
        { nombre: 'p_domicilio', valor: formData.value.domicilio, tipo: 'string' },
        { nombre: 'p_actividad', valor: formData.value.actividad, tipo: 'string' },
        { nombre: 'p_no_exterior', valor: formData.value.no_exterior || null, tipo: 'string' },
        { nombre: 'p_no_interior', valor: formData.value.no_interior || null, tipo: 'string' },
        { nombre: 'p_supconst', valor: formData.value.supconst || null, tipo: 'double precision' },
        { nombre: 'p_area_util', valor: formData.value.area_util || null, tipo: 'double precision' },
        { nombre: 'p_num_cajones', valor: formData.value.num_cajones || 0, tipo: 'integer' },
        { nombre: 'p_uso_suelo', valor: formData.value.uso_suelo || null, tipo: 'string' },
        { nombre: 'p_desc_uso', valor: formData.value.desc_uso || null, tipo: 'string' },
        { nombre: 'p_zona', valor: formData.value.zona || null, tipo: 'integer' },
        { nombre: 'p_subzona', valor: formData.value.subzona || null, tipo: 'string' },
        { nombre: 'p_dictamen', valor: formData.value.dictamen, tipo: 'string' }
      ],
      '', null, 'comun'
    )

    if (response && response.result && response.result[0]?.success) {
      await Swal.fire({
        title: '¡Éxito!',
        text: response.result[0].message,
        icon: 'success',
        confirmButtonColor: '#ea8215',
        timer: 3000,
        timerProgressBar: true
      })
      closeFormModal()
    } else {
      throw new Error(response.result[0]?.message || 'No se pudo actualizar el dictamen')
    }
  } catch (error) {
    handleApiError(error, 'Error al actualizar el dictamen')
  } finally {
    saving.value = false
  }
}

const closeFormModal = () => {
  showFormModal.value = false
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
}

// Utilidades
const toggleFilters = () => {
  showFilters.value = !showFilters.value
}

const openDocumentation = () => {
  showDocumentation.value = true
}

const closeDocumentation = () => {
  showDocumentation.value = false
}

const formatDate = (date) => {
  if (!date) return 'N/A'
  return new Date(date).toLocaleDateString('es-MX')
}

const formatNumber = (num, decimals = 0) => {
  if (num === null || num === undefined) return '0'
  return Number(num).toLocaleString('es-MX', {
    minimumFractionDigits: decimals,
    maximumFractionDigits: decimals
  })
}

const calculatePercentage = (part, total) => {
  if (!total || total === 0) return '0.0'
  return ((part / total) * 100).toFixed(1)
}

const trimString = (str) => {
  if (!str) return ''
  return String(str).trim()
}

const getDictamenText = (valor) => {
  const val = trimString(valor)
  switch (val) {
    case '1': return 'APROBADO'
    case '0': return 'NEGADO'
    case '2': return 'EN PROCESO'
    case '3': return 'PENDIENTE'
    default: return 'DESCONOCIDO'
  }
}

const getDictamenBadgeClass = (valor) => {
  const val = trimString(valor)
  switch (val) {
    case '1': return 'badge-success'
    case '0': return 'badge-danger'
    case '2': return 'badge-warning'
    case '3': return 'badge-info'
    default: return 'badge-secondary'
  }
}
</script>
