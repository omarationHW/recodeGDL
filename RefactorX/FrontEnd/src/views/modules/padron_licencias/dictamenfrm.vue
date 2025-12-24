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
          class="btn-municipal-success"
          @click="openCreateModal"
        >
          <font-awesome-icon icon="plus" />
          Nuevo
        </button>
        <button
          class="btn-municipal-primary"
          @click="buscar"
        >
          <font-awesome-icon icon="sync-alt" />
          Actualizar
        </button>
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
                <button @click="buscar" class="btn-municipal-primary">
                  <font-awesome-icon icon="search" /> Buscar
                </button>
                <button @click="limpiarFiltros" class="btn-municipal-secondary">
                  <font-awesome-icon icon="eraser" /> Limpiar
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
          <div class="header-right">
            <span class="badge-purple" v-if="dictamenes.length > 0">
              {{ dictamenes.length }} registros
            </span>
          </div>
        </div>
        <div class="municipal-card-body table-container">
          <!-- Empty State - Sin búsqueda -->
          <div v-if="dictamenes.length === 0 && !hasSearched" class="empty-state">
            <div class="empty-state-icon">
              <font-awesome-icon icon="clipboard-check" size="3x" />
            </div>
            <h4>Gestión de Dictámenes</h4>
            <p>Utiliza los filtros de búsqueda para consultar dictámenes de uso de suelo</p>
          </div>

          <!-- Empty State - Sin resultados -->
          <div v-else-if="dictamenes.length === 0 && hasSearched" class="empty-state">
            <div class="empty-state-icon">
              <font-awesome-icon icon="inbox" size="3x" />
            </div>
            <h4>Sin resultados</h4>
            <p>No se encontraron registros con los criterios especificados</p>
          </div>

          <div v-else class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th class="w-5">
                    <font-awesome-icon icon="hashtag" class="me-2" />
                    ID
                  </th>
                  <th class="w-20">
                    <font-awesome-icon icon="user" class="me-2" />
                    Propietario
                  </th>
                  <th class="w-20">
                    <font-awesome-icon icon="map-marker-alt" class="me-2" />
                    Domicilio
                  </th>
                  <th class="w-20">
                    <font-awesome-icon icon="briefcase" class="me-2" />
                    Actividad
                  </th>
                  <th class="w-8 text-right">
                    <font-awesome-icon icon="ruler" class="me-1" />
                    Área Útil (m²)
                  </th>
                  <th class="w-5 text-center">
                    <font-awesome-icon icon="parking" class="me-1" />
                    Cajones
                  </th>
                  <th class="w-7 text-center">
                    <font-awesome-icon icon="map-pin" class="me-1" />
                    Zona/Subzona
                  </th>
                  <th class="w-8 text-center">
                    <font-awesome-icon icon="gavel" class="me-1" />
                    Dictamen
                  </th>
                  <th class="w-7 text-center">
                    <font-awesome-icon icon="calendar" class="me-1" />
                    Fecha
                  </th>
                  <th class="w-10 text-center">
                    <font-awesome-icon icon="cog" class="me-1" />
                    Acciones
                  </th>
                </tr>
              </thead>
              <tbody>
                <tr
                  v-for="dictamen in dictamenes"
                  :key="dictamen.id_dictamen"
                  @click="selectedRow = dictamen"
                  :class="{ 'table-row-selected': selectedRow === dictamen }"
                  class="row-hover"
                >
                  <td>
                    <span class="badge badge-light-info">{{ dictamen.id_dictamen }}</span>
                  </td>
                  <td>
                    <div class="text-truncate">{{ trimString(dictamen.propietario) }}</div>
                  </td>
                  <td>
                    <div class="text-truncate">
                      {{ trimString(dictamen.domicilio) }} {{ trimString(dictamen.no_exterior) }}
                    </div>
                  </td>
                  <td>
                    <div class="text-truncate">{{ trimString(dictamen.actividad) }}</div>
                  </td>
                  <td class="text-right">{{ dictamen.area_util ? dictamen.area_util.toFixed(2) : '0.00' }}</td>
                  <td class="text-center">{{ dictamen.num_cajones || 0 }}</td>
                  <td class="text-center">{{ dictamen.zona }}/{{ dictamen.subzona }}</td>
                  <td class="text-center">
                    <span class="badge" :class="getDictamenBadgeClass(dictamen.dictamen)">
                      {{ getDictamenText(dictamen.dictamen) }}
                    </span>
                  </td>
                  <td class="text-center">{{ formatDate(dictamen.fecha) }}</td>
                  <td class="text-center">
                    <div class="button-group button-group-sm">
                      <button
                        class="btn-municipal-info btn-sm"
                        @click.stop="verDetalle(dictamen)"
                        title="Ver detalles"
                      >
                        <font-awesome-icon icon="eye" />
                      </button>
                      <button
                        class="btn-municipal-primary btn-sm"
                        @click.stop="editarDictamen(dictamen)"
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
        </div>

        <!-- Paginación -->
        <div v-if="dictamenes.length > 0" class="pagination-controls">
          <div class="pagination-info">
            <span class="text-muted">
              Mostrando {{ ((currentPage - 1) * pageSize) + 1 }}
              a {{ Math.min(currentPage * pageSize, totalRecords) }}
              de {{ formatNumber(totalRecords) }} registros
            </span>
          </div>

          <div class="pagination-size">
            <label class="municipal-form-label me-2">Registros por página:</label>
            <select
              class="municipal-form-control form-control-sm"
              :value="pageSize"
              @change="changePageSize($event.target.value)"
              style="width: auto; display: inline-block;"
            >
              <option value="10">10</option>
              <option value="20">20</option>
              <option value="50">50</option>
              <option value="100">100</option>
            </select>
          </div>

          <div class="pagination-buttons">
            <button class="btn-municipal-secondary btn-sm" @click="changePage(1)" :disabled="currentPage === 1">
              <font-awesome-icon icon="angle-double-left" />
            </button>
            <button class="btn-municipal-secondary btn-sm" @click="changePage(currentPage - 1)" :disabled="currentPage === 1">
              <font-awesome-icon icon="angle-left" />
            </button>
            <button
              v-for="page in visiblePages"
              :key="page"
              class="btn-sm"
              :class="page === currentPage ? 'btn-municipal-primary' : 'btn-municipal-secondary'"
              @click="changePage(page)"
            >
              {{ page }}
            </button>
            <button class="btn-municipal-secondary btn-sm" @click="changePage(currentPage + 1)" :disabled="currentPage === totalPages">
              <font-awesome-icon icon="angle-right" />
            </button>
            <button class="btn-municipal-secondary btn-sm" @click="changePage(totalPages)" :disabled="currentPage === totalPages">
              <font-awesome-icon icon="angle-double-right" />
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
          Detalle del Dictamen #{{ selectedDictamen?.id_dictamen }}
        </h5>
      </template>

      <div v-if="selectedDictamen" class="modal-body-detail">
        <!-- Resumen superior con badges -->
        <div class="detail-summary-bar">
          <div class="summary-item">
            <span class="summary-label">ID Dictamen</span>
            <span class="badge badge-primary-modern">{{ selectedDictamen.id_dictamen }}</span>
          </div>
          <div class="summary-item">
            <span class="summary-label">Estado</span>
            <span class="badge" :class="getDictamenBadgeClass(selectedDictamen.dictamen)">
              {{ getDictamenText(selectedDictamen.dictamen) }}
            </span>
          </div>
          <div class="summary-item">
            <span class="summary-label">Fecha</span>
            <span class="badge badge-purple-modern">
              <font-awesome-icon icon="calendar" class="me-1" />
              {{ formatDate(selectedDictamen.fecha) }}
            </span>
          </div>
          <div class="summary-item">
            <span class="summary-label">Zona</span>
            <span class="badge badge-secondary-modern">{{ selectedDictamen.zona }}/{{ selectedDictamen.subzona }}</span>
          </div>
        </div>

        <!-- Grid de detalles -->
        <div class="details-grid">
          <!-- Propietario y Ubicación -->
          <div class="detail-section">
            <h6 class="detail-section-title">
              <font-awesome-icon icon="user" class="me-2" />
              Propietario y Ubicación
            </h6>
            <table class="detail-table">
              <tr>
                <td class="label">Propietario:</td>
                <td><strong>{{ trimString(selectedDictamen.propietario) }}</strong></td>
              </tr>
              <tr>
                <td class="label">Domicilio:</td>
                <td>{{ trimString(selectedDictamen.domicilio) }}</td>
              </tr>
              <tr>
                <td class="label">No. Exterior:</td>
                <td>{{ trimString(selectedDictamen.no_exterior) || 'N/A' }}</td>
              </tr>
              <tr>
                <td class="label">No. Interior:</td>
                <td>{{ trimString(selectedDictamen.no_interior) || 'N/A' }}</td>
              </tr>
            </table>
          </div>

          <!-- Características del Inmueble -->
          <div class="detail-section">
            <h6 class="detail-section-title">
              <font-awesome-icon icon="building" class="me-2" />
              Características del Inmueble
            </h6>
            <table class="detail-table">
              <tr>
                <td class="label">Superficie Construida:</td>
                <td>
                  <span class="badge badge-light-info">
                    <font-awesome-icon icon="ruler-combined" class="me-1" />
                    {{ selectedDictamen.supconst ? selectedDictamen.supconst.toFixed(2) : '0.00' }} m²
                  </span>
                </td>
              </tr>
              <tr>
                <td class="label">Área Útil:</td>
                <td>
                  <span class="badge badge-light-success">
                    <font-awesome-icon icon="ruler" class="me-1" />
                    {{ selectedDictamen.area_util ? selectedDictamen.area_util.toFixed(2) : '0.00' }} m²
                  </span>
                </td>
              </tr>
              <tr>
                <td class="label">Número de Cajones:</td>
                <td>
                  <span class="badge badge-light-warning">
                    <font-awesome-icon icon="parking" class="me-1" />
                    {{ selectedDictamen.num_cajones || 0 }}
                  </span>
                </td>
              </tr>
              <tr>
                <td class="label">ID Giro:</td>
                <td>
                  <span class="badge badge-light-secondary">{{ selectedDictamen.id_giro || 'N/A' }}</span>
                </td>
              </tr>
            </table>
          </div>
        </div>

        <!-- Sección completa: Actividad y Uso de Suelo -->
        <div class="detail-section detail-section-full">
          <h6 class="detail-section-title">
            <font-awesome-icon icon="briefcase" class="me-2" />
            Actividad y Uso de Suelo
          </h6>
          <table class="detail-table">
            <tr>
              <td class="label">Actividad:</td>
              <td><strong>{{ trimString(selectedDictamen.actividad) }}</strong></td>
            </tr>
            <tr>
              <td class="label">Uso de Suelo:</td>
              <td class="text-muted">{{ trimString(selectedDictamen.uso_suelo) || 'No especificado' }}</td>
            </tr>
            <tr>
              <td class="label">Descripción de Uso:</td>
              <td class="text-muted">{{ trimString(selectedDictamen.desc_uso) || 'No especificado' }}</td>
            </tr>
            <tr v-if="selectedDictamen.capturista">
              <td class="label">Capturista:</td>
              <td>
                <font-awesome-icon icon="user-tie" class="me-1 text-muted" />
                {{ trimString(selectedDictamen.capturista) }}
              </td>
            </tr>
          </table>
        </div>
      </div>

      <template #footer>
        <button class="btn-municipal-secondary" @click="showDetailModal = false">
          <font-awesome-icon icon="times" /> Cerrar
        </button>
        <button class="btn-municipal-primary" @click="editarDesdeDetalle">
          <font-awesome-icon icon="edit" /> Editar
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
        <!-- Sección: Propietario y Ubicación -->
        <div class="form-section">
          <h6 class="form-section-title">
            <font-awesome-icon icon="user" class="me-2" />
            Propietario y Ubicación
          </h6>
          <div class="form-row">
            <div class="form-group col-12">
              <label class="municipal-form-label">Propietario <span class="required">*</span></label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="formData.propietario"
                required
                maxlength="100"
                placeholder="Nombre completo del propietario"
              />
            </div>
          </div>

          <div class="form-row">
            <div class="form-group col-6">
              <label class="municipal-form-label">Domicilio <span class="required">*</span></label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="formData.domicilio"
                required
                maxlength="100"
                placeholder="Calle y número"
              />
            </div>

            <div class="form-group col-3">
              <label class="municipal-form-label">No. Exterior</label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="formData.no_exterior"
                maxlength="5"
                placeholder="123"
              />
            </div>

            <div class="form-group col-3">
              <label class="municipal-form-label">No. Interior</label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="formData.no_interior"
                maxlength="5"
                placeholder="A, B-1"
              />
            </div>
          </div>
        </div>

        <!-- Sección: Actividad Comercial -->
        <div class="form-section">
          <h6 class="form-section-title">
            <font-awesome-icon icon="briefcase" class="me-2" />
            Actividad Comercial
          </h6>
          <div class="form-row">
            <div class="form-group col-8">
              <label class="municipal-form-label">Actividad <span class="required">*</span></label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="formData.actividad"
                required
                maxlength="100"
                placeholder="Descripción de la actividad comercial"
              />
            </div>

            <div class="form-group col-4">
              <label class="municipal-form-label">ID Giro <span class="required">*</span></label>
              <input
                type="number"
                class="municipal-form-control"
                v-model.number="formData.id_giro"
                required
                min="0"
                placeholder="ID del giro"
              />
            </div>
          </div>

          <div class="form-row">
            <div class="form-group col-6">
              <label class="municipal-form-label">Uso de Suelo</label>
              <textarea
                class="municipal-form-control"
                v-model="formData.uso_suelo"
                rows="3"
                maxlength="200"
                placeholder="Uso de suelo permitido..."
              ></textarea>
            </div>

            <div class="form-group col-6">
              <label class="municipal-form-label">Descripción de Uso</label>
              <textarea
                class="municipal-form-control"
                v-model="formData.desc_uso"
                rows="3"
                maxlength="120"
                placeholder="Descripción adicional..."
              ></textarea>
            </div>
          </div>
        </div>

        <!-- Sección: Características del Inmueble -->
        <div class="form-section">
          <h6 class="form-section-title">
            <font-awesome-icon icon="building" class="me-2" />
            Características del Inmueble
          </h6>
          <div class="form-row">
            <div class="form-group col-4">
              <label class="municipal-form-label">Superficie Construida (m²)</label>
              <input
                type="number"
                step="0.01"
                class="municipal-form-control"
                v-model.number="formData.supconst"
                min="0"
                placeholder="0.00"
              />
            </div>

            <div class="form-group col-4">
              <label class="municipal-form-label">Área Útil (m²)</label>
              <input
                type="number"
                step="0.01"
                class="municipal-form-control"
                v-model.number="formData.area_util"
                min="0"
                placeholder="0.00"
              />
            </div>

            <div class="form-group col-4">
              <label class="municipal-form-label">Número de Cajones</label>
              <input
                type="number"
                class="municipal-form-control"
                v-model.number="formData.num_cajones"
                min="0"
                placeholder="0"
              />
            </div>
          </div>
        </div>

        <!-- Sección: Dictamen y Zonificación -->
        <div class="form-section">
          <h6 class="form-section-title">
            <font-awesome-icon icon="gavel" class="me-2" />
            Dictamen y Zonificación
          </h6>
          <div class="form-row">
            <div class="form-group col-3">
              <label class="municipal-form-label">Zona <span class="required">*</span></label>
              <input
                type="number"
                class="municipal-form-control"
                v-model.number="formData.zona"
                required
                min="0"
                placeholder="0"
              />
            </div>

            <div class="form-group col-3">
              <label class="municipal-form-label">Subzona <span class="required">*</span></label>
              <input
                type="number"
                class="municipal-form-control"
                v-model.number="formData.subzona"
                required
                min="0"
                placeholder="0"
              />
            </div>

            <div class="form-group col-6">
              <label class="municipal-form-label">Resultado del Dictamen <span class="required">*</span></label>
              <select class="municipal-form-control" v-model="formData.dictamen" required>
                <option value="" disabled>Seleccione un resultado...</option>
                <option value="0">❌ NEGADO</option>
                <option value="1">✅ APROBADO</option>
                <option value="2">⏳ EN PROCESO</option>
                <option value="3">📋 PENDIENTE</option>
              </select>
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

    <!-- Modal de Ayuda/Documentación -->
    <DocumentationModal
      :show="showDocModal"
      :componentName="'dictamenfrm'"
      :moduleName="'padron_licencias'"
      :docType="docType"
      :title="'Dictamen'"
      @close="showDocModal = false"
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
const { execute } = useApi()
const { toast, showToast, hideToast, getToastIcon, handleApiError } = useLicenciasErrorHandler()
const { showLoading, hideLoading } = useGlobalLoading()

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
const dictamenes = ref([])
const selectedDictamen = ref(null)
const selectedRow = ref(null)
const hasSearched = ref(false)
const showDetailModal = ref(false)
const showFormModal = ref(false)
const isEditing = ref(false)
const saving = ref(false)
const showFilters = ref(false)
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

const startRecord = computed(() => {
  if (totalRecords.value === 0) return 0
  return ((currentPage.value - 1) * pageSize.value) + 1
})

const endRecord = computed(() => {
  const end = currentPage.value * pageSize.value
  return Math.min(end, totalRecords.value)
})

const visiblePages = computed(() => {
  const pages = []
  const start = Math.max(1, currentPage.value - 2)
  const end = Math.min(totalPages.value, currentPage.value + 2)

  for (let i = start; i <= end; i++) {
    pages.push(i)
  }
  return pages
})

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
      '', null, 'publico'
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
  hasSearched.value = false
  selectedRow.value = null
}

const loadDictamenes = async () => {
  showLoading('Cargando dictámenes...', 'Buscando registros en la base de datos')
  hasSearched.value = true
  selectedRow.value = null
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
      '', null, 'publico'
    )

    const endTime = performance.now()
    const responseTime = Math.round(endTime - startTime)

    hideLoading()

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
    hideLoading()
    handleApiError(error, 'Error al buscar dictámenes')
  }
}

const changePage = (page) => {
  if (page >= 1 && page <= totalPages.value) {
    currentPage.value = page
    selectedRow.value = null
    loadDictamenes()
  }
}

const changePageSize = (size) => {
  pageSize.value = parseInt(size)
  currentPage.value = 1
  selectedRow.value = null
  loadDictamenes()
}

// Métodos de detalle - CORREGIDO: Ya no recarga
const verDetalle = (dictamen) => {
  selectedDictamen.value = dictamen
  showDetailModal.value = true
}

const editarDesdeDetalle = () => {
  showDetailModal.value = false
  editarDictamen(selectedDictamen.value)
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

// CORREGIDO: Ya no recarga, usa el parámetro directamente
const editarDictamen = (dictamen) => {
  isEditing.value = true
  formData.value = {
    id_dictamen: dictamen.id_dictamen,
    id_giro: dictamen.id_giro || 0,
    propietario: trimString(dictamen.propietario),
    domicilio: trimString(dictamen.domicilio),
    no_exterior: trimString(dictamen.no_exterior) || '',
    no_interior: trimString(dictamen.no_interior) || '',
    supconst: dictamen.supconst || 0,
    area_util: dictamen.area_util || 0,
    num_cajones: dictamen.num_cajones || 0,
    actividad: trimString(dictamen.actividad),
    uso_suelo: trimString(dictamen.uso_suelo) || '',
    desc_uso: trimString(dictamen.desc_uso) || '',
    zona: dictamen.zona,
    subzona: dictamen.subzona,
    dictamen: trimString(dictamen.dictamen)
  }
  showFormModal.value = true
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
      '', null, 'publico'
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
      await loadDictamenes() // Recargar lista
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
      '', null, 'publico'
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
      await loadDictamenes() // Recargar lista
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
    case '3': return 'badge-purple'
    default: return 'badge-secondary'
  }
}
</script>

<style scoped>
/* ========================================
   ESTILOS DE TABLA - COLUMNAS OPTIMIZADAS
   ======================================== */

/* Tabla con layout fijo para anchos controlados */
.municipal-table {
  table-layout: fixed;
  width: 100%;
}

/* Anchos de columnas específicos */
.municipal-table th.w-5,
.municipal-table td:nth-child(1) { width: 60px; }

.municipal-table th.w-20:nth-child(2),
.municipal-table td:nth-child(2) { width: 150px; }

.municipal-table th.w-20:nth-child(3),
.municipal-table td:nth-child(3) { width: 150px; }

.municipal-table th.w-20:nth-child(4),
.municipal-table td:nth-child(4) { width: 140px; }

.municipal-table th.w-8,
.municipal-table td:nth-child(5) { width: 80px; }

.municipal-table th:nth-child(6),
.municipal-table td:nth-child(6) { width: 60px; }

.municipal-table th.w-7:nth-child(7),
.municipal-table td:nth-child(7) { width: 80px; }

.municipal-table th:nth-child(8),
.municipal-table td:nth-child(8) { width: 90px; }

.municipal-table th:nth-child(9),
.municipal-table td:nth-child(9) { width: 85px; }

.municipal-table th.w-10,
.municipal-table td:nth-child(10) { width: 90px; }

/* Texto truncado con ellipsis */
.text-truncate {
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  max-width: 100%;
  display: block;
}

/* Celdas de encabezado más compactas */
.municipal-table-header th {
  font-size: 0.8rem;
  padding: 0.5rem 0.4rem;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

/* Celdas de datos más compactas */
.municipal-table tbody td {
  font-size: 0.85rem;
  padding: 0.4rem;
  vertical-align: middle;
}

/* Badge más compacto */
.badge {
  font-size: 0.7rem;
  padding: 0.25rem 0.5rem;
}

/* Botones de acción más pequeños */
.button-group-sm .btn-sm {
  padding: 0.2rem 0.4rem;
  font-size: 0.75rem;
}

/* Container responsive */
.table-container {
  overflow-x: auto;
  max-width: 100%;
}

.table-responsive {
  overflow-x: auto;
  -webkit-overflow-scrolling: touch;
}
</style>
