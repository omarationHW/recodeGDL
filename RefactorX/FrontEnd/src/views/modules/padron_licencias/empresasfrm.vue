<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="briefcase" />
      </div>
      <div class="module-view-info">
        <h1>Gestión de Empresas</h1>
        <p>Padrón de Licencias - Registro y Administración de Empresas/Contribuyentes</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-success" @click="openCreateModal">
          <font-awesome-icon icon="plus" />
          Nueva Empresa
        </button>
        <button class="btn-municipal-primary" @click="buscarEmpresas">
          <font-awesome-icon icon="sync-alt" />
          Actualizar
        </button>
        <button class="btn-municipal-purple" @click="openDocumentation">
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
      </div>
    </div>

    <div class="module-view-content">

    <!-- Stats Cards -->
    <div class="stats-grid">
      <div class="stat-card stat-card-primary">
        <div class="stat-icon">
          <font-awesome-icon icon="briefcase" />
        </div>
        <div class="stat-details">
          <div class="stat-label">Total Empresas</div>
          <div v-if="loadingStats" class="skeleton-loader"></div>
          <div v-else class="stat-value">{{ stats.total_empresas || 0 }}</div>
        </div>
      </div>

      <div class="stat-card stat-card-success">
        <div class="stat-icon">
          <font-awesome-icon icon="check-circle" />
        </div>
        <div class="stat-details">
          <div class="stat-label">Vigentes</div>
          <div v-if="loadingStats" class="skeleton-loader"></div>
          <div v-else class="stat-value">{{ stats.empresas_vigentes || 0 }}</div>
        </div>
      </div>

      <div class="stat-card stat-card-warning">
        <div class="stat-icon">
          <font-awesome-icon icon="file-alt" />
        </div>
        <div class="stat-details">
          <div class="stat-label">Con RFC</div>
          <div v-if="loadingStats" class="skeleton-loader"></div>
          <div v-else class="stat-value">{{ stats.empresas_con_rfc || 0 }}</div>
        </div>
      </div>

      <div class="stat-card stat-card-info">
        <div class="stat-icon">
          <font-awesome-icon icon="users" />
        </div>
        <div class="stat-details">
          <div class="stat-label">Promedio Empleados</div>
          <div v-if="loadingStats" class="skeleton-loader"></div>
          <div v-else class="stat-value">{{ stats.promedio_empleados ? parseFloat(stats.promedio_empleados).toFixed(0) : 'N/A' }}</div>
        </div>
      </div>
    </div>

    <!-- Filtros de búsqueda -->
    <div class="municipal-card">
      <div class="municipal-card-header clickable-header" @click="showFilters = !showFilters">
        <h5>
          <font-awesome-icon :icon="showFilters ? 'chevron-down' : 'chevron-right'" class="me-2" />
          Filtros de Búsqueda
        </h5>
      </div>
      <div class="municipal-card-body" v-show="showFilters">
        <div class="form-row">
          <div class="form-group">
            <label class="municipal-form-label">Empresa ID</label>
            <input
              type="number"
              class="municipal-form-control"
              v-model="filters.empresa"
              placeholder="ID de empresa"
            >
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Propietario</label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="filters.propietario"
              placeholder="Nombre del propietario"
            >
          </div>
          <div class="form-group">
            <label class="municipal-form-label">RFC</label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="filters.rfc"
              placeholder="RFC"
              maxlength="13"
            >
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Vigencia</label>
            <select class="municipal-form-control" v-model="filters.vigente">
              <option value="">Todas</option>
              <option value="S">Vigentes</option>
              <option value="N">No Vigentes</option>
            </select>
          </div>
        </div>
        <div class="button-group">
          <button
            class="btn-municipal-primary"
            @click="buscarEmpresas"
          >
            <font-awesome-icon icon="search" />
            Buscar
          </button>
          <button
            class="btn-municipal-secondary"
            @click="limpiarFiltros"
          >
            <font-awesome-icon icon="times" />
            Limpiar
          </button>
        </div>
      </div>
    </div>

    <!-- Tabla de resultados -->
    <div class="municipal-card">
      <div class="municipal-card-header header-with-badge">
        <h5>
          <font-awesome-icon icon="list" />
          Resultados de Búsqueda
        </h5>
        <span class="badge-purple" v-if="empresas.length > 0">
          {{ totalRecords }} registro{{ totalRecords !== 1 ? 's' : '' }}
        </span>
      </div>

      <div class="municipal-card-body">
        <div class="table-responsive" v-if="empresas.length > 0">
          <table class="municipal-table">
            <thead class="municipal-table-header">
              <tr>
                <th class="w-5"><font-awesome-icon icon="hashtag" class="me-2" />ID</th>
                <th class="w-20"><font-awesome-icon icon="user" class="me-2" />Propietario</th>
                <th class="w-10"><font-awesome-icon icon="file-alt" class="me-2" />RFC</th>
                <th class="w-20"><font-awesome-icon icon="map-marker-alt" class="me-2" />Ubicación</th>
                <th class="w-15"><font-awesome-icon icon="building" class="me-2" />Colonia</th>
                <th class="w-10"><font-awesome-icon icon="layer-group" class="me-2" />Zona</th>
                <th class="w-10 text-center"><font-awesome-icon icon="toggle-on" class="me-2" />Vigente</th>
                <th class="w-10 text-center"><font-awesome-icon icon="cog" class="me-1" />Acciones</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="empresa in empresas" :key="empresa.empresa" class="row-hover">
                <td><strong class="text-primary">{{ empresa.empresa }}</strong></td>
                <td>{{ trimString(empresa.propietario) || 'N/A' }}</td>
                <td><code>{{ trimString(empresa.rfc) || 'N/A' }}</code></td>
                <td>{{ trimString(empresa.ubicacion) || 'N/A' }} {{ empresa.numext_ubic || '' }}</td>
                <td>{{ trimString(empresa.colonia_ubic) || 'N/A' }}</td>
                <td>
                  <span class="badge-secondary">Z-{{ empresa.zona || 'N/A' }} / SZ-{{ empresa.subzona || 'N/A' }}</span>
                </td>
                <td class="text-center">
                  <span class="badge" :class="empresa.vigente === 'S' ? 'badge-success' : 'badge-danger'">
                    <font-awesome-icon :icon="empresa.vigente === 'S' ? 'check-circle' : 'times-circle'" />
                    {{ empresa.vigente === 'S' ? 'Vigente' : 'No Vigente' }}
                  </span>
                </td>
                <td class="text-center">
                  <div class="button-group button-group-sm">
                    <button
                      class="btn-municipal-info btn-sm"
                      @click="verEmpresa(empresa)"
                      title="Ver detalles"
                    >
                      <font-awesome-icon icon="eye" />
                    </button>
                    <button
                      class="btn-municipal-primary btn-sm"
                      @click="editarEmpresa(empresa)"
                      title="Editar"
                    >
                      <font-awesome-icon icon="edit" />
                    </button>
                    <button
                      class="btn-municipal-danger btn-sm"
                      @click="confirmarEliminarEmpresa(empresa)"
                      title="Eliminar"
                    >
                      <font-awesome-icon icon="trash" />
                    </button>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>

        <!-- Empty State -->
        <div v-else class="empty-state">
          <div class="empty-icon">
            <font-awesome-icon icon="briefcase" size="3x" />
          </div>
          <h5>No hay empresas registradas</h5>
          <p>Utiliza los filtros para buscar o registra una nueva empresa</p>
        </div>

        <!-- Paginación -->
        <div class="table-footer" v-if="empresas.length > 0">
          <div class="showing-text">
            Mostrando {{ ((currentPage - 1) * itemsPerPage) + 1 }} a
            {{ Math.min(currentPage * itemsPerPage, totalRecords) }} de
            {{ totalRecords }} registros
          </div>

          <div class="pagination-controls">
            <div class="page-size-selector">
              <label>Mostrar:</label>
              <select v-model="itemsPerPage" @change="currentPage = 1; buscarEmpresas()">
                <option :value="10">10</option>
                <option :value="20">20</option>
                <option :value="50">50</option>
                <option :value="100">100</option>
              </select>
            </div>

            <div class="pagination-nav">
              <button
                class="pagination-button"
                @click="currentPage--; buscarEmpresas()"
                :disabled="currentPage === 1"
              >
                <font-awesome-icon icon="chevron-left" />
              </button>

              <button
                v-for="page in visiblePages"
                :key="page"
                class="pagination-button"
                :class="{ active: page === currentPage, 'pagination-ellipsis': page === '...' }"
                @click="page !== '...' && (currentPage = page, buscarEmpresas())"
                :disabled="page === '...'"
              >
                {{ page }}
              </button>

              <button
                class="pagination-button"
                @click="currentPage++; buscarEmpresas()"
                :disabled="currentPage === totalPages"
              >
                <font-awesome-icon icon="chevron-right" />
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal de creación -->
    <Modal
      :show="showCreateModal"
      title="Crear Nueva Empresa"
      size="xl"
      @close="showCreateModal = false"
      @confirm="crearEmpresa"
      :loading="creatingEmpresa"
      confirmText="Crear Empresa"
      cancelText="Cancelar"
      :showDefaultFooter="true"
      :confirmButtonClass="'btn-municipal-primary'"
    >
      <form @submit.prevent="crearEmpresa">
        <div class="form-section">
          <h6 class="form-section-title">
            <font-awesome-icon icon="user" class="me-2" />
            Datos del Propietario
          </h6>
          <div class="form-row">
            <div class="form-group col-6">
              <label class="municipal-form-label">Propietario <span class="required">*</span></label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="newEmpresa.propietario"
                required
                maxlength="80"
                placeholder="Nombre completo del propietario"
              >
            </div>
            <div class="form-group col-6">
              <label class="municipal-form-label">RFC</label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="newEmpresa.rfc"
                maxlength="13"
                placeholder="RFC (13 caracteres)"
              >
            </div>
          </div>
          <div class="form-row">
            <div class="form-group col-6">
              <label class="municipal-form-label">CURP</label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="newEmpresa.curp"
                maxlength="18"
                placeholder="CURP (18 caracteres)"
              >
            </div>
            <div class="form-group col-6">
              <label class="municipal-form-label">Email</label>
              <input
                type="email"
                class="municipal-form-control"
                v-model="newEmpresa.email"
                maxlength="100"
                placeholder="correo@ejemplo.com"
              >
            </div>
          </div>
          <div class="form-row">
            <div class="form-group col-12">
              <label class="municipal-form-label">Teléfono</label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="newEmpresa.telefono"
                maxlength="30"
                placeholder="Número de teléfono"
              >
            </div>
          </div>
        </div>

        <div class="form-section">
          <h6 class="form-section-title">
            <font-awesome-icon icon="map-marker-alt" class="me-2" />
            Ubicación del Negocio
          </h6>
          <div class="form-row">
            <div class="form-group col-8">
              <label class="municipal-form-label">Ubicación <span class="required">*</span></label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="newEmpresa.ubicacion"
                required
                maxlength="50"
                placeholder="Calle y dirección"
              >
            </div>
            <div class="form-group col-4">
              <label class="municipal-form-label">Número Exterior</label>
              <input
                type="number"
                class="municipal-form-control"
                v-model="newEmpresa.numext_ubic"
                placeholder="Núm. ext."
              >
            </div>
          </div>
          <div class="form-row">
            <div class="form-group col-6">
              <label class="municipal-form-label">Colonia</label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="newEmpresa.colonia_ubic"
                maxlength="25"
                placeholder="Colonia"
              >
            </div>
            <div class="form-group col-6">
              <label class="municipal-form-label">Código Postal</label>
              <input
                type="number"
                class="municipal-form-control"
                v-model="newEmpresa.cp"
                placeholder="CP"
              >
            </div>
          </div>
        </div>

        <div class="form-section">
          <h6 class="form-section-title">
            <font-awesome-icon icon="building" class="me-2" />
            Datos del Establecimiento
          </h6>
          <div class="form-row">
            <div class="form-group col-6">
              <label class="municipal-form-label">Superficie Construida (m²)</label>
              <input
                type="number"
                class="municipal-form-control"
                v-model="newEmpresa.sup_construida"
                step="0.01"
                placeholder="0.00"
              >
            </div>
            <div class="form-group col-6">
              <label class="municipal-form-label">Superficie Autorizada (m²)</label>
              <input
                type="number"
                class="municipal-form-control"
                v-model="newEmpresa.sup_autorizada"
                step="0.01"
                placeholder="0.00"
              >
            </div>
          </div>
          <div class="form-row">
            <div class="form-group col-6">
              <label class="municipal-form-label">Número de Empleados</label>
              <input
                type="number"
                class="municipal-form-control"
                v-model="newEmpresa.num_empleados"
                placeholder="0"
              >
            </div>
            <div class="form-group col-6">
              <label class="municipal-form-label">Aforo</label>
              <input
                type="number"
                class="municipal-form-control"
                v-model="newEmpresa.aforo"
                placeholder="0"
              >
            </div>
          </div>
          <div class="form-row">
            <div class="form-group col-4">
              <label class="municipal-form-label">Zona</label>
              <input
                type="number"
                class="municipal-form-control"
                v-model="newEmpresa.zona"
                placeholder="Zona"
              >
            </div>
            <div class="form-group col-4">
              <label class="municipal-form-label">Subzona</label>
              <input
                type="number"
                class="municipal-form-control"
                v-model="newEmpresa.subzona"
                placeholder="Subzona"
              >
            </div>
            <div class="form-group col-4">
              <label class="municipal-form-label">Vigente</label>
              <select class="municipal-form-control" v-model="newEmpresa.vigente">
                <option value="S">Sí</option>
                <option value="N">No</option>
              </select>
            </div>
          </div>
        </div>
      </form>
    </Modal>

    <!-- Modal de edición -->
    <Modal
      :show="showEditModal"
      :title="`Editar Empresa: ${selectedEmpresa?.empresa}`"
      size="xl"
      @close="showEditModal = false"
      @confirm="actualizarEmpresa"
      :loading="updatingEmpresa"
      confirmText="Guardar Cambios"
      cancelText="Cancelar"
      :showDefaultFooter="true"
      :confirmButtonClass="'btn-municipal-primary'"
    >
      <form @submit.prevent="actualizarEmpresa" v-if="editForm">
        <div class="form-section">
          <h6 class="form-section-title">
            <font-awesome-icon icon="user" class="me-2" />
            Datos del Propietario
          </h6>
          <div class="form-row">
            <div class="form-group col-6">
              <label class="municipal-form-label">Propietario <span class="required">*</span></label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="editForm.propietario"
                required
                maxlength="80"
              >
            </div>
            <div class="form-group col-6">
              <label class="municipal-form-label">RFC</label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="editForm.rfc"
                maxlength="13"
              >
            </div>
          </div>
          <div class="form-row">
            <div class="form-group col-6">
              <label class="municipal-form-label">Email</label>
              <input
                type="email"
                class="municipal-form-control"
                v-model="editForm.email"
                maxlength="100"
              >
            </div>
            <div class="form-group col-6">
              <label class="municipal-form-label">Teléfono</label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="editForm.telefono"
                maxlength="30"
              >
            </div>
          </div>
        </div>

        <div class="form-section">
          <h6 class="form-section-title">
            <font-awesome-icon icon="map-marker-alt" class="me-2" />
            Ubicación
          </h6>
          <div class="form-row">
            <div class="form-group col-8">
              <label class="municipal-form-label">Ubicación</label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="editForm.ubicacion"
                maxlength="50"
              >
            </div>
            <div class="form-group col-4">
              <label class="municipal-form-label">Número Ext.</label>
              <input
                type="number"
                class="municipal-form-control"
                v-model="editForm.numext_ubic"
              >
            </div>
          </div>
          <div class="form-row">
            <div class="form-group col-6">
              <label class="municipal-form-label">Colonia</label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="editForm.colonia_ubic"
                maxlength="25"
              >
            </div>
            <div class="form-group col-6">
              <label class="municipal-form-label">Vigente</label>
              <select class="municipal-form-control" v-model="editForm.vigente">
                <option value="S">Sí</option>
                <option value="N">No</option>
              </select>
            </div>
          </div>
          <div class="form-row">
            <div class="form-group col-6">
              <label class="municipal-form-label">Zona</label>
              <input
                type="number"
                class="municipal-form-control"
                v-model="editForm.zona"
              >
            </div>
            <div class="form-group col-6">
              <label class="municipal-form-label">Subzona</label>
              <input
                type="number"
                class="municipal-form-control"
                v-model="editForm.subzona"
              >
            </div>
          </div>
        </div>
      </form>
    </Modal>

    <!-- Modal de visualización -->
    <Modal
      :show="showViewModal"
      @close="showViewModal = false"
      size="xl"
    >
      <template #header>
        <h5 class="modal-title">
          <font-awesome-icon icon="eye" class="me-2 text-info" />
          Detalle de Empresa #{{ selectedEmpresa?.empresa }}
        </h5>
      </template>

      <div v-if="selectedEmpresa" class="modal-body-detail">
        <!-- Resumen superior con badges -->
        <div class="detail-summary-bar">
          <div class="summary-item">
            <span class="summary-label">ID Empresa</span>
            <span class="badge badge-primary-modern">{{ selectedEmpresa.empresa }}</span>
          </div>
          <div class="summary-item">
            <span class="summary-label">Estado</span>
            <span class="badge" :class="selectedEmpresa.vigente === 'S' ? 'badge-success' : 'badge-danger'">
              {{ selectedEmpresa.vigente === 'S' ? 'Vigente' : 'No Vigente' }}
            </span>
          </div>
          <div class="summary-item">
            <span class="summary-label">Zona</span>
            <span class="badge badge-secondary-modern">{{ selectedEmpresa.zona || 'N/A' }}/{{ selectedEmpresa.subzona || 'N/A' }}</span>
          </div>
        </div>

        <!-- Grid de detalles -->
        <div class="details-grid">
          <!-- Propietario -->
          <div class="detail-section">
            <h6 class="detail-section-title">
              <font-awesome-icon icon="user" class="me-2" />
              Información del Propietario
            </h6>
            <table class="detail-table">
              <tr>
                <td class="label">Propietario:</td>
                <td><strong>{{ trimString(selectedEmpresa.propietario) }}</strong></td>
              </tr>
              <tr>
                <td class="label">RFC:</td>
                <td><code>{{ trimString(selectedEmpresa.rfc) || 'N/A' }}</code></td>
              </tr>
              <tr>
                <td class="label">Email:</td>
                <td>{{ trimString(selectedEmpresa.email) || 'N/A' }}</td>
              </tr>
              <tr>
                <td class="label">Teléfono:</td>
                <td>{{ trimString(selectedEmpresa.telefono) || 'N/A' }}</td>
              </tr>
            </table>
          </div>

          <!-- Ubicación -->
          <div class="detail-section">
            <h6 class="detail-section-title">
              <font-awesome-icon icon="map-marker-alt" class="me-2" />
              Ubicación del Establecimiento
            </h6>
            <table class="detail-table">
              <tr>
                <td class="label">Ubicación:</td>
                <td>{{ trimString(selectedEmpresa.ubicacion) }}</td>
              </tr>
              <tr>
                <td class="label">Número Exterior:</td>
                <td>{{ selectedEmpresa.numext_ubic || 'N/A' }}</td>
              </tr>
              <tr>
                <td class="label">Colonia:</td>
                <td>{{ trimString(selectedEmpresa.colonia_ubic) || 'N/A' }}</td>
              </tr>
              <tr>
                <td class="label">Código Postal:</td>
                <td>{{ selectedEmpresa.cp || 'N/A' }}</td>
              </tr>
            </table>
          </div>
        </div>

        <!-- Sección completa: Características del Establecimiento -->
        <div class="detail-section detail-section-full">
          <h6 class="detail-section-title">
            <font-awesome-icon icon="building" class="me-2" />
            Características del Establecimiento
          </h6>
          <table class="detail-table">
            <tr>
              <td class="label">Superficie Construida:</td>
              <td>
                <span class="badge badge-light-info" v-if="selectedEmpresa.sup_construida">
                  <font-awesome-icon icon="ruler-combined" class="me-1" />
                  {{ parseFloat(selectedEmpresa.sup_construida).toFixed(2) }} m²
                </span>
                <span v-else class="text-muted">No especificado</span>
              </td>
            </tr>
            <tr>
              <td class="label">Superficie Autorizada:</td>
              <td>
                <span class="badge badge-light-success" v-if="selectedEmpresa.sup_autorizada">
                  <font-awesome-icon icon="ruler" class="me-1" />
                  {{ parseFloat(selectedEmpresa.sup_autorizada).toFixed(2) }} m²
                </span>
                <span v-else class="text-muted">No especificado</span>
              </td>
            </tr>
            <tr>
              <td class="label">Número de Empleados:</td>
              <td>
                <span class="badge badge-light-warning">
                  <font-awesome-icon icon="users" class="me-1" />
                  {{ selectedEmpresa.num_empleados || 0 }}
                </span>
              </td>
            </tr>
            <tr>
              <td class="label">Aforo:</td>
              <td>
                <span class="badge badge-light-secondary">
                  <font-awesome-icon icon="user-friends" class="me-1" />
                  {{ selectedEmpresa.aforo || 0 }}
                </span>
              </td>
            </tr>
          </table>
        </div>
      </div>

      <template #footer>
        <button class="btn-municipal-secondary" @click="showViewModal = false">
          <font-awesome-icon icon="times" /> Cerrar
        </button>
        <button class="btn-municipal-primary" @click="editarEmpresa(selectedEmpresa); showViewModal = false">
          <font-awesome-icon icon="edit" /> Editar
        </button>
      </template>
    </Modal>

    </div>
    <!-- /module-view-content -->

    <!-- Toast Notifications -->
    <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
      <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
      <div class="toast-content">
        <span class="toast-message">{{ toast.message }}</span>
        <span v-if="toast.duration" class="toast-duration">
          <font-awesome-icon icon="clock" class="toast-duration-icon" />
          {{ toast.duration }}
        </span>
      </div>
      <button class="toast-close" @click="hideToast">
        <font-awesome-icon icon="times" />
      </button>
    </div>

    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showDocumentation"
      :componentName="'empresasfrm'"
      :moduleName="'padron_licencias'"
      @close="closeDocumentation"
    />
  </div>
  <!-- /module-view -->
</template>

<script setup>
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { ref, computed, onMounted } from 'vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import Modal from '@/components/common/Modal.vue'
import Swal from 'sweetalert2'

// Composables
const showDocumentation = ref(false)
const openDocumentation = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false

const { execute } = useApi()
const { toast, showToast, hideToast, getToastIcon, handleApiError } = useLicenciasErrorHandler()
const { showLoading, hideLoading } = useGlobalLoading()

// Estado
const empresas = ref([])
const selectedEmpresa = ref(null)
const showCreateModal = ref(false)
const showEditModal = ref(false)
const showViewModal = ref(false)
const creatingEmpresa = ref(false)
const updatingEmpresa = ref(false)
const showFilters = ref(false)
const loadingStats = ref(false)

// Paginación
const currentPage = ref(1)
const itemsPerPage = ref(10)
const totalRecords = ref(0)

const totalPages = computed(() => Math.ceil(totalRecords.value / itemsPerPage.value))

// Páginas visibles para paginación
const visiblePages = computed(() => {
  const pages = []
  const total = totalPages.value
  const current = currentPage.value

  if (total <= 7) {
    // Si hay 7 páginas o menos, mostrar todas
    for (let i = 1; i <= total; i++) {
      pages.push(i)
    }
  } else {
    // Mostrar páginas con elipsis
    if (current <= 4) {
      // Inicio: 1 2 3 4 5 ... N
      for (let i = 1; i <= 5; i++) pages.push(i)
      pages.push('...')
      pages.push(total)
    } else if (current >= total - 3) {
      // Final: 1 ... N-4 N-3 N-2 N-1 N
      pages.push(1)
      pages.push('...')
      for (let i = total - 4; i <= total; i++) pages.push(i)
    } else {
      // Medio: 1 ... current-1 current current+1 ... N
      pages.push(1)
      pages.push('...')
      for (let i = current - 1; i <= current + 1; i++) pages.push(i)
      pages.push('...')
      pages.push(total)
    }
  }

  return pages
})

// Stats
const stats = ref({
  total_empresas: 0,
  empresas_vigentes: 0,
  empresas_no_vigentes: 0,
  empresas_con_rfc: 0,
  promedio_empleados: 0,
  promedio_superficie: 0,
  total_zonas: 0,
  empresas_mes_actual: 0
})

// Filtros
const filters = ref({
  empresa: null,
  propietario: '',
  rfc: '',
  vigente: ''
})

// Formularios
const newEmpresa = ref({
  propietario: '',
  rfc: '',
  curp: '',
  domicilio: '',
  email: '',
  telefono: '',
  ubicacion: '',
  numext_ubic: null,
  colonia_ubic: '',
  cp: null,
  sup_construida: null,
  sup_autorizada: null,
  num_empleados: null,
  aforo: null,
  zona: null,
  subzona: null,
  vigente: 'S'
})

const editForm = ref(null)

// Helper
const trimString = (str) => {
  return str ? str.trim() : ''
}

// Métodos
const loadStats = async () => {
  loadingStats.value = true
  try {
    const response = await execute(
      'sp_empresas_estadisticas',
      'padron_licencias',
      [],
      '', null, 'publico'
    )

    if (response && response.result && response.result.length > 0) {
      stats.value = response.result[0]
    }
  } catch (error) {
  } finally {
    loadingStats.value = false
  }
}

const buscarEmpresas = async () => {
  showLoading('Cargando empresas...', 'Buscando registros en la base de datos')
  try {
    const startTime = performance.now()

    const response = await execute(
      'sp_empresas_list',
      'padron_licencias',
      [
        { nombre: 'p_page', valor: currentPage.value },
        { nombre: 'p_page_size', valor: itemsPerPage.value },
        { nombre: 'p_empresa', valor: filters.value.empresa || null },
        { nombre: 'p_propietario', valor: filters.value.propietario || null },
        { nombre: 'p_rfc', valor: filters.value.rfc || null },
        { nombre: 'p_vigente', valor: filters.value.vigente || null }
      ],
      '', null, 'publico'
    )

    const endTime = performance.now()
    const responseTime = Math.round(endTime - startTime)

    hideLoading()

    if (response && response.result && response.result.length > 0) {
      empresas.value = response.result
      totalRecords.value = parseInt(response.result[0].total_count) || 0

      const timeText = responseTime < 1000
        ? `${responseTime}ms`
        : `${(responseTime / 1000).toFixed(2)}s`

      showToast('success', `${totalRecords.value} empresas encontradas`, timeText)
    } else {
      empresas.value = []
      totalRecords.value = 0
      showToast('info', 'No se encontraron empresas con los criterios especificados')
    }

    // Actualizar stats
    loadStats()
  } catch (error) {
    hideLoading()
    handleApiError(error, 'Error al buscar empresas')
  }
}

const limpiarFiltros = () => {
  filters.value = {
    empresa: null,
    propietario: '',
    rfc: '',
    vigente: ''
  }
  empresas.value = []
  currentPage.value = 1
  totalRecords.value = 0
}

const openCreateModal = () => {
  newEmpresa.value = {
    propietario: '',
    rfc: '',
    curp: '',
    domicilio: '',
    email: '',
    telefono: '',
    ubicacion: '',
    numext_ubic: null,
    colonia_ubic: '',
    cp: null,
    sup_construida: null,
    sup_autorizada: null,
    num_empleados: null,
    aforo: null,
    zona: null,
    subzona: null,
    vigente: 'S'
  }
  showCreateModal.value = true
}

const crearEmpresa = async () => {
  if (!newEmpresa.value.propietario || !newEmpresa.value.ubicacion) {
    await Swal.fire({
      icon: 'warning',
      title: 'Campos requeridos',
      text: 'Por favor complete los campos obligatorios',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  const confirmResult = await Swal.fire({
    icon: 'question',
    title: '¿Confirmar creación de empresa?',
    text: `Se creará una nueva empresa para ${newEmpresa.value.propietario}`,
    showCancelButton: true,
    confirmButtonColor: '#ea8215',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, crear empresa',
    cancelButtonText: 'Cancelar'
  })

  if (!confirmResult.isConfirmed) return

  creatingEmpresa.value = true
  try {
    const response = await execute(
      'sp_empresas_create',
      'padron_licencias',
      [
        { nombre: 'p_propietario', valor: newEmpresa.value.propietario },
        { nombre: 'p_ubicacion', valor: newEmpresa.value.ubicacion },
        { nombre: 'p_rfc', valor: newEmpresa.value.rfc || null },
        { nombre: 'p_curp', valor: newEmpresa.value.curp || null },
        { nombre: 'p_domicilio', valor: newEmpresa.value.domicilio || null },
        { nombre: 'p_email', valor: newEmpresa.value.email || null },
        { nombre: 'p_telefono', valor: newEmpresa.value.telefono || null },
        { nombre: 'p_numext_ubic', valor: newEmpresa.value.numext_ubic },
        { nombre: 'p_numint_ubic', valor: null },
        { nombre: 'p_colonia_ubic', valor: newEmpresa.value.colonia_ubic || null },
        { nombre: 'p_cp', valor: newEmpresa.value.cp },
        { nombre: 'p_sup_construida', valor: newEmpresa.value.sup_construida },
        { nombre: 'p_sup_autorizada', valor: newEmpresa.value.sup_autorizada },
        { nombre: 'p_num_empleados', valor: newEmpresa.value.num_empleados },
        { nombre: 'p_aforo', valor: newEmpresa.value.aforo },
        { nombre: 'p_zona', valor: newEmpresa.value.zona },
        { nombre: 'p_subzona', valor: newEmpresa.value.subzona },
        { nombre: 'p_vigente', valor: newEmpresa.value.vigente }
      ],
      '', null, 'publico'
    )

    if (response && response.result) {
      showCreateModal.value = false
      await Swal.fire({
        icon: 'success',
        title: '¡Empresa creada!',
        text: 'La empresa ha sido creada exitosamente',
        confirmButtonColor: '#ea8215',
        timer: 2000
      })
      showToast('success', 'Empresa creada exitosamente')
      buscarEmpresas()
    }
  } catch (error) {
    handleApiError(error, 'Error al crear empresa')
  } finally {
    creatingEmpresa.value = false
  }
}

const editarEmpresa = (empresa) => {
  selectedEmpresa.value = empresa
  editForm.value = {
    empresa: empresa.empresa,
    propietario: trimString(empresa.propietario) || '',
    rfc: trimString(empresa.rfc) || '',
    email: trimString(empresa.email) || '',
    telefono: trimString(empresa.telefono) || '',
    ubicacion: trimString(empresa.ubicacion) || '',
    numext_ubic: empresa.numext_ubic,
    colonia_ubic: trimString(empresa.colonia_ubic) || '',
    zona: empresa.zona,
    subzona: empresa.subzona,
    vigente: empresa.vigente || 'S'
  }
  showEditModal.value = true
}

const actualizarEmpresa = async () => {
  if (!editForm.value.propietario) {
    await Swal.fire({
      icon: 'warning',
      title: 'Campo requerido',
      text: 'El propietario es obligatorio',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  const confirmResult = await Swal.fire({
    icon: 'question',
    title: '¿Confirmar actualización?',
    text: 'Se actualizarán los datos de la empresa',
    showCancelButton: true,
    confirmButtonColor: '#ea8215',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, guardar cambios',
    cancelButtonText: 'Cancelar'
  })

  if (!confirmResult.isConfirmed) return

  updatingEmpresa.value = true
  try {
    const response = await execute(
      'sp_empresas_update',
      'padron_licencias',
      [
        { nombre: 'p_empresa', valor: editForm.value.empresa },
        { nombre: 'p_propietario', valor: editForm.value.propietario },
        { nombre: 'p_rfc', valor: editForm.value.rfc },
        { nombre: 'p_email', valor: editForm.value.email },
        { nombre: 'p_telefono', valor: editForm.value.telefono },
        { nombre: 'p_ubicacion', valor: editForm.value.ubicacion },
        { nombre: 'p_numext_ubic', valor: editForm.value.numext_ubic },
        { nombre: 'p_colonia_ubic', valor: editForm.value.colonia_ubic },
        { nombre: 'p_zona', valor: editForm.value.zona },
        { nombre: 'p_subzona', valor: editForm.value.subzona },
        { nombre: 'p_vigente', valor: editForm.value.vigente }
      ],
      '', null, 'publico'
    )

    if (response && response.result) {
      showEditModal.value = false
      await Swal.fire({
        icon: 'success',
        title: '¡Empresa actualizada!',
        text: 'Los datos han sido actualizados',
        confirmButtonColor: '#ea8215',
        timer: 2000
      })
      showToast('success', 'Empresa actualizada exitosamente')
      buscarEmpresas()
    }
  } catch (error) {
    handleApiError(error, 'Error al actualizar empresa')
  } finally {
    updatingEmpresa.value = false
  }
}

const verEmpresa = (empresa) => {
  selectedEmpresa.value = empresa
  showViewModal.value = true
}

const confirmarEliminarEmpresa = async (empresa) => {
  const result = await Swal.fire({
    title: '¿Eliminar empresa?',
    text: `¿Está seguro de eliminar la empresa ${empresa.empresa}?`,
    icon: 'warning',
    showCancelButton: true,
    confirmButtonColor: '#dc3545',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, eliminar',
    cancelButtonText: 'Cancelar'
  })

  if (result.isConfirmed) {
    await eliminarEmpresa(empresa)
  }
}

const eliminarEmpresa = async (empresa) => {
  try {
    const response = await execute(
      'sp_empresas_delete',
      'padron_licencias',
      [
        { nombre: 'p_empresa', valor: empresa.empresa }
      ],
      '', null, 'publico'
    )

    if (response && response.result) {
      await Swal.fire({
        icon: 'success',
        title: '¡Empresa eliminada!',
        text: 'La empresa ha sido eliminada',
        confirmButtonColor: '#ea8215',
        timer: 2000
      })
      showToast('success', 'Empresa eliminada exitosamente')
      buscarEmpresas()
    }
  } catch (error) {
    handleApiError(error, 'Error al eliminar empresa')
  }
}

// Lifecycle
onMounted(() => {
  loadStats()
})
</script>
