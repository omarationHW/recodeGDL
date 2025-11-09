<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="file-certificate" />
      </div>
      <div class="module-view-info">
        <h1>Gestión de Constancias</h1>
        <p>Padrón de Licencias - Administración de constancias oficiales</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-success" @click="abrirModalNuevo">
          <font-awesome-icon icon="plus" />
          Nueva Constancia
        </button>
        <button class="btn-municipal-primary" @click="cargarConstancias">
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
      <!-- Stats grid -->
      <div class="stats-grid" v-if="loadingEstadisticas">
        <div class="stat-card stat-card-loading" v-for="n in 3" :key="`loading-${n}`">
          <div class="stat-content">
            <div class="skeleton-icon"></div>
            <div class="skeleton-number"></div>
            <div class="skeleton-label"></div>
            <div class="skeleton-percentage"></div>
          </div>
        </div>
      </div>

      <div class="stats-grid" v-else-if="estadisticas.length > 0">
        <div class="stat-card" v-for="stat in estadisticas" :key="stat.vigente" :class="`stat-${stat.vigente}`">
          <div class="stat-content">
            <div class="stat-icon">
              <font-awesome-icon :icon="getVigenteIcon(stat.vigente)" />
            </div>
            <h3 class="stat-number">{{ formatNumber(stat.total) }}</h3>
            <p class="stat-label">{{ stat.descripcion }}</p>
            <small class="stat-percentage">{{ stat.porcentaje }}%</small>
          </div>
        </div>
      </div>

      <!-- Filtros de búsqueda -->
      <div class="municipal-card">
        <div class="municipal-card-header" @click="toggleFilters" style="cursor: pointer;">
          <h5>
            <font-awesome-icon icon="filter" />
            Filtros de Búsqueda
            <font-awesome-icon :icon="showFilters ? 'chevron-up' : 'chevron-down'" class="ms-2" />
          </h5>
        </div>

        <div v-show="showFilters" class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Año</label>
              <input
                type="number"
                class="municipal-form-control"
                v-model="filtros.axo"
                placeholder="Año"
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Folio</label>
              <input
                type="number"
                class="municipal-form-control"
                v-model="filtros.folio"
                placeholder="Folio"
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">ID Licencia</label>
              <input
                type="number"
                class="municipal-form-control"
                v-model="filtros.id_licencia"
                placeholder="ID de licencia"
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Solicitante</label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="filtros.solicita"
                placeholder="Nombre del solicitante"
              />
            </div>
          </div>

          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Vigente</label>
              <select class="municipal-form-control" v-model="filtros.vigente">
                <option value="">Todos</option>
                <option value="V">Vigente</option>
                <option value="C">Cancelado</option>
              </select>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">
                Fecha Desde
                <small class="text-muted" style="font-weight: normal; margin-left: 0.5rem;">(últimos 6 meses)</small>
              </label>
              <input
                type="date"
                class="municipal-form-control"
                v-model="filtros.fecha_desde"
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">
                Fecha Hasta
                <small class="text-muted" style="font-weight: normal; margin-left: 0.5rem;">(hoy)</small>
              </label>
              <input
                type="date"
                class="municipal-form-control"
                v-model="filtros.fecha_hasta"
              />
            </div>
            <div class="form-group" style="align-self: flex-end;">
              <button class="btn-municipal-primary w-100" @click="buscarConstancias">
                <font-awesome-icon icon="search" />
                Buscar
              </button>
            </div>
          </div>
          <div class="form-row" style="margin-top: 0;">
            <div class="form-group full-width">
              <small class="text-info" style="display: flex; align-items: center; gap: 0.5rem;">
                <font-awesome-icon icon="info-circle" />
                Por defecto se muestran las constancias de los últimos 6 meses. Ajuste las fechas para ampliar o reducir el rango de búsqueda.
              </small>
            </div>
          </div>
        </div>
      </div>

      <!-- Tabla de resultados -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <div class="header-with-badge">
            <h5>
              <font-awesome-icon icon="list" />
              Constancias Registradas
            </h5>
            <span class="badge-purple" v-if="totalResultados > 0">
              {{ formatNumber(totalResultados) }} registros totales
            </span>
          </div>
        </div>

        <div class="municipal-card-body table-container">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Año</th>
                  <th>Folio</th>
                  <th>Licencia</th>
                  <th>Solicitante</th>
                  <th>Propietario</th>
                  <th>Vigente</th>
                  <th>Fecha</th>
                  <th>Acciones</th>
                </tr>
              </thead>
              <tbody>
                <tr v-if="constancias.length === 0 && !primeraBusqueda">
                  <td colspan="8" class="text-center text-muted">
                    <font-awesome-icon icon="search" size="2x" class="empty-icon" />
                    <p>Utiliza los filtros para buscar constancias o crea una nueva</p>
                  </td>
                </tr>
                <tr v-else-if="constancias.length === 0">
                  <td colspan="8" class="text-center text-muted">
                    <font-awesome-icon icon="inbox" size="2x" class="empty-icon" />
                    <p>No se encontraron constancias con los filtros especificados</p>
                  </td>
                </tr>
                <tr
                  v-else
                  v-for="constancia in constancias"
                  :key="`${constancia.axo}-${constancia.folio}`"
                  @click="constanciaSeleccionada = constancia"
                  style="cursor: pointer;"
                >
                  <td>
                    <div class="folio-display">
                      <span class="folio-year">{{ constancia.axo }}</span>
                    </div>
                  </td>
                  <td>
                    <div class="folio-display">
                      <span class="folio-number">#{{ constancia.folio }}</span>
                    </div>
                  </td>
                  <td>
                    <div class="licencia-badge-container">
                      <span v-if="constancia.id_licencia" class="badge badge-purple licencia-badge">
                        <font-awesome-icon icon="file-contract" />
                        Lic. {{ constancia.id_licencia }}
                      </span>
                      <span v-else class="badge badge-secondary licencia-badge">
                        <font-awesome-icon icon="times-circle" />
                        Sin licencia
                      </span>
                    </div>
                  </td>
                  <td>{{ constancia.solicita || 'N/A' }}</td>
                  <td><small>{{ constancia.propietario || 'N/A' }}</small></td>
                  <td>
                    <span
                      :class="{
                        'badge': true,
                        'badge-success': constancia.vigente === 'V',
                        'badge-danger': constancia.vigente === 'C'
                      }"
                    >
                      <font-awesome-icon :icon="getVigenteIcon(constancia.vigente)" />
                      {{ getVigenteDesc(constancia.vigente) }}
                    </span>
                  </td>
                  <td>
                    <small>{{ formatDate(constancia.feccap) }}</small>
                  </td>
                  <td>
                    <div class="button-group button-group-sm">
                      <button
                        class="btn-municipal-info btn-sm"
                        @click.stop="verDetalle(constancia)"
                        title="Ver detalles"
                      >
                        <font-awesome-icon icon="eye" />
                      </button>
                      <button
                        class="btn-municipal-primary btn-sm"
                        @click.stop="editarConstancia(constancia)"
                        title="Editar"
                      >
                        <font-awesome-icon icon="edit" />
                      </button>
                      <button
                        v-if="constancia.vigente === 'V'"
                        class="btn-municipal-danger btn-sm"
                        @click.stop="confirmarEliminar(constancia)"
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
          <div class="pagination-controls" v-if="totalResultados > itemsPerPage">
            <div class="pagination-info">
              <span class="text-muted">
                Mostrando {{ ((currentPage - 1) * itemsPerPage) + 1 }}
                a {{ Math.min(currentPage * itemsPerPage, totalResultados) }}
                de {{ totalResultados }} registros
              </span>
            </div>

            <div class="pagination-size">
              <label class="municipal-form-label me-2">Registros por página:</label>
              <select
                class="municipal-form-control form-control-sm"
                v-model="itemsPerPage"
                @change="changePageSize"
                style="width: auto; display: inline-block;"
              >
                <option :value="10">10</option>
                <option :value="20">20</option>
                <option :value="50">50</option>
                <option :value="100">100</option>
              </select>
            </div>

            <div class="pagination-buttons">
              <button
                class="btn-municipal-secondary btn-sm"
                @click="goToPage(1)"
                :disabled="currentPage === 1"
                title="Primera página"
              >
                <font-awesome-icon icon="angle-double-left" />
              </button>

              <button
                class="btn-municipal-secondary btn-sm"
                @click="goToPage(currentPage - 1)"
                :disabled="currentPage === 1"
                title="Página anterior"
              >
                <font-awesome-icon icon="angle-left" />
              </button>

              <button
                v-for="page in visiblePages"
                :key="page"
                class="btn-sm"
                :class="page === currentPage ? 'btn-municipal-primary' : 'btn-municipal-secondary'"
                @click="goToPage(page)"
              >
                {{ page }}
              </button>

              <button
                class="btn-municipal-secondary btn-sm"
                @click="goToPage(currentPage + 1)"
                :disabled="currentPage === totalPages"
                title="Página siguiente"
              >
                <font-awesome-icon icon="angle-right" />
              </button>

              <button
                class="btn-municipal-secondary btn-sm"
                @click="goToPage(totalPages)"
                :disabled="currentPage === totalPages"
                title="Última página"
              >
                <font-awesome-icon icon="angle-double-right" />
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal Detalle -->
    <Modal
      :show="showDetalleModal"
      @close="showDetalleModal = false"
      size="xl"
      title="Detalle de Constancia"
      :showDefaultFooter="false"
      class="modal-constancia-detalle"
    >
      <div v-if="constanciaSeleccionada" class="tramite-details">
        <div class="details-grid">
          <div class="detail-section">
            <h6 class="section-title">
              <font-awesome-icon icon="info-circle" />
              Información General
            </h6>
            <table class="detail-table">
              <tr>
                <td class="label">Año / Folio:</td>
                <td><strong class="text-primary">{{ constanciaSeleccionada.axo }} / {{ constanciaSeleccionada.folio }}</strong></td>
              </tr>
              <tr>
                <td class="label">ID Licencia:</td>
                <td><strong>{{ constanciaSeleccionada.id_licencia || 'N/A' }}</strong></td>
              </tr>
              <tr>
                <td class="label">Vigente:</td>
                <td>
                  <span
                    :class="{
                      'badge': true,
                      'badge-success': constanciaSeleccionada.vigente === 'V',
                      'badge-danger': constanciaSeleccionada.vigente === 'C'
                    }"
                  >
                    <font-awesome-icon :icon="getVigenteIcon(constanciaSeleccionada.vigente)" />
                    {{ getVigenteDesc(constanciaSeleccionada.vigente) }}
                  </span>
                </td>
              </tr>
              <tr>
                <td class="label">Fecha Captura:</td>
                <td>
                  <font-awesome-icon icon="calendar" class="text-success" />
                  {{ formatDate(constanciaSeleccionada.feccap) }}
                </td>
              </tr>
              <tr>
                <td class="label">Capturista:</td>
                <td><code>{{ constanciaSeleccionada.capturista || 'N/A' }}</code></td>
              </tr>
            </table>
          </div>

          <div class="detail-section">
            <h6 class="section-title">
              <font-awesome-icon icon="user" />
              Datos del Solicitante
            </h6>
            <table class="detail-table">
              <tr>
                <td class="label">Nombre:</td>
                <td>{{ constanciaSeleccionada.solicita || 'N/A' }}</td>
              </tr>
              <tr>
                <td class="label">Propietario Licencia:</td>
                <td>{{ constanciaSeleccionada.propietario || 'N/A' }}</td>
              </tr>
              <tr>
                <td class="label">Partida Pago:</td>
                <td><code>{{ constanciaSeleccionada.partidapago || 'N/A' }}</code></td>
              </tr>
              <tr>
                <td class="label">Domicilio:</td>
                <td>{{ constanciaSeleccionada.domicilio || 'N/A' }}</td>
              </tr>
              <tr>
                <td class="label">Tipo:</td>
                <td>{{ constanciaSeleccionada.tipo || 'N/A' }}</td>
              </tr>
            </table>
          </div>
        </div>

        <div class="detail-section full-width">
          <h6 class="section-title">
            <font-awesome-icon icon="comment" />
            Observaciones
          </h6>
          <p>{{ constanciaSeleccionada.observacion || 'Sin observaciones' }}</p>
        </div>
      </div>
    </Modal>

    <!-- Modal Nueva Constancia -->
    <Modal
      :show="showModalNuevo"
      @close="cerrarModalNuevo"
      size="xl"
      :showDefaultFooter="false"
      class="modal-constancia-form"
    >
      <template #header>
        <h5 class="modal-title">
          <font-awesome-icon icon="plus-circle" class="me-2" />
          Nueva Constancia
        </h5>
      </template>

      <div class="form-section">
        <h6 class="form-section-title">
          <font-awesome-icon icon="file-alt" class="me-2" />
          Datos de la Constancia
        </h6>
        <div class="form-row">
          <div class="form-group col-4">
            <label class="municipal-form-label">Año <span class="required">*</span></label>
            <input
              type="number"
              class="municipal-form-control"
              v-model="formNuevo.axo"
              placeholder="Año"
            />
          </div>
          <div class="form-group col-4">
            <label class="municipal-form-label">Folio <span class="required">*</span></label>
            <input
              type="number"
              class="municipal-form-control"
              v-model="formNuevo.folio"
              placeholder="Auto-calculado"
              readonly
            />
          </div>
          <div class="form-group col-4">
            <label class="municipal-form-label">ID Licencia <span class="required">*</span></label>
            <input
              type="number"
              class="municipal-form-control"
              v-model="formNuevo.id_licencia"
              placeholder="ID de licencia"
            />
          </div>
        </div>
      </div>

      <div class="form-section">
        <h6 class="form-section-title">
          <font-awesome-icon icon="user" class="me-2" />
          Información del Solicitante
        </h6>
        <div class="form-row">
          <div class="form-group full-width">
            <label class="municipal-form-label">Nombre Completo del Solicitante <span class="required">*</span></label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="formNuevo.solicita"
              placeholder="Nombre completo del solicitante"
              style="text-transform: uppercase;"
            />
          </div>
        </div>

        <div class="form-row">
          <div class="form-group full-width">
            <label class="municipal-form-label">Domicilio</label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="formNuevo.domicilio"
              placeholder="Calle, número, colonia"
            />
          </div>
        </div>
      </div>

      <div class="form-section">
        <h6 class="form-section-title">
          <font-awesome-icon icon="receipt" class="me-2" />
          Datos de Pago
        </h6>
        <div class="form-row">
          <div class="form-group col-6">
            <label class="municipal-form-label">Partida de Pago</label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="formNuevo.partidapago"
              placeholder="Número de partida"
            />
          </div>
          <div class="form-group col-6">
            <label class="municipal-form-label">Tipo</label>
            <input
              type="number"
              class="municipal-form-control"
              v-model="formNuevo.tipo"
              placeholder="Tipo de constancia"
            />
          </div>
        </div>
      </div>

      <div class="form-section">
        <h6 class="form-section-title">
          <font-awesome-icon icon="comment" class="me-2" />
          Observaciones
        </h6>
        <div class="form-row">
          <div class="form-group full-width">
            <label class="municipal-form-label">Observaciones</label>
            <textarea
              class="municipal-form-control"
              v-model="formNuevo.observacion"
              placeholder="Observaciones generales de la constancia"
              rows="4"
            ></textarea>
          </div>
        </div>
      </div>

      <div class="modal-actions">
        <button class="btn-municipal-secondary" @click="cerrarModalNuevo">
          <font-awesome-icon icon="times" />
          Cancelar
        </button>
        <button
          class="btn-municipal-primary"
          @click="crearConstancia"
          :disabled="loadingModal"
        >
          <font-awesome-icon icon="save" />
          Guardar
        </button>
      </div>
    </Modal>

    <!-- Modal Editar Constancia -->
    <Modal
      :show="showModalEditar"
      @close="cerrarModalEditar"
      size="xl"
      :showDefaultFooter="false"
      class="modal-constancia-form"
    >
      <template #header>
        <h5 class="modal-title">
          <font-awesome-icon icon="edit" class="me-2" />
          Editar Constancia
        </h5>
      </template>

      <div class="form-section">
        <h6 class="form-section-title">
          <font-awesome-icon icon="file-alt" class="me-2" />
          Datos de la Constancia
        </h6>
        <div class="form-row">
          <div class="form-group col-4">
            <label class="municipal-form-label">Año</label>
            <input
              type="number"
              class="municipal-form-control"
              v-model="formEditar.axo"
              disabled
            />
          </div>
          <div class="form-group col-4">
            <label class="municipal-form-label">Folio</label>
            <input
              type="number"
              class="municipal-form-control"
              v-model="formEditar.folio"
              disabled
            />
          </div>
          <div class="form-group col-4">
            <label class="municipal-form-label">ID Licencia <span class="required">*</span></label>
            <input
              type="number"
              class="municipal-form-control"
              v-model="formEditar.id_licencia"
              placeholder="ID de licencia"
            />
          </div>
        </div>
      </div>

      <div class="form-section">
        <h6 class="form-section-title">
          <font-awesome-icon icon="user" class="me-2" />
          Información del Solicitante
        </h6>
        <div class="form-row">
          <div class="form-group full-width">
            <label class="municipal-form-label">Nombre Completo del Solicitante <span class="required">*</span></label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="formEditar.solicita"
              placeholder="Nombre completo del solicitante"
              style="text-transform: uppercase;"
            />
          </div>
        </div>

        <div class="form-row">
          <div class="form-group full-width">
            <label class="municipal-form-label">Domicilio</label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="formEditar.domicilio"
              placeholder="Calle, número, colonia"
            />
          </div>
        </div>
      </div>

      <div class="form-section">
        <h6 class="form-section-title">
          <font-awesome-icon icon="receipt" class="me-2" />
          Datos de Pago
        </h6>
        <div class="form-row">
          <div class="form-group col-6">
            <label class="municipal-form-label">Partida de Pago</label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="formEditar.partidapago"
              placeholder="Número de partida"
            />
          </div>
          <div class="form-group col-6">
            <label class="municipal-form-label">Tipo</label>
            <input
              type="number"
              class="municipal-form-control"
              v-model="formEditar.tipo"
              placeholder="Tipo de constancia"
            />
          </div>
        </div>
      </div>

      <div class="form-section">
        <h6 class="form-section-title">
          <font-awesome-icon icon="comment" class="me-2" />
          Observaciones
        </h6>
        <div class="form-row">
          <div class="form-group full-width">
            <label class="municipal-form-label">Observaciones</label>
            <textarea
              class="municipal-form-control"
              v-model="formEditar.observacion"
              placeholder="Observaciones generales de la constancia"
              rows="4"
            ></textarea>
          </div>
        </div>
      </div>

      <div class="modal-actions">
        <button class="btn-municipal-secondary" @click="cerrarModalEditar">
          <font-awesome-icon icon="times" />
          Cancelar
        </button>
        <button
          class="btn-municipal-primary"
          @click="actualizarConstancia"
          :disabled="loadingModal"
        >
          <font-awesome-icon icon="save" />
          Actualizar
        </button>
      </div>
    </Modal>

    <!-- Toast -->
    <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
      <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
      <span class="toast-message">{{ toast.message }}</span>
      <button class="toast-close" @click="hideToast">
        <font-awesome-icon icon="times" />
      </button>
    </div>

    <!-- Documentation Modal -->
    <DocumentationModal
      v-if="showDocumentation"
      :componentName="'constanciafrm'"
      :moduleName="'padron_licencias'"
      @close="closeDocumentation"
    />
  </div>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import { useRouter } from 'vue-router'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import Modal from '@/components/common/Modal.vue'
import { useApi } from '@/composables/useApi'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import Swal from 'sweetalert2'

// Composables
const showDocumentation = ref(false)
const openDocumentation = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false

const router = useRouter()
const { execute } = useApi()
const { showLoading, hideLoading } = useGlobalLoading()
const {
  toast,
  showToast,
  hideToast,
  getToastIcon,
  handleApiError
} = useLicenciasErrorHandler()

// Estado
const showFilters = ref(false)
const constancias = ref([])
const estadisticas = ref([])
const totalResultados = ref(0)
const currentPage = ref(1)
const itemsPerPage = ref(10)
const primeraBusqueda = ref(false)
const loadingEstadisticas = ref(true)
const loadingModal = ref(false)

// Modales
const showDetalleModal = ref(false)
const showModalNuevo = ref(false)
const showModalEditar = ref(false)
const constanciaSeleccionada = ref({})

// Función para obtener fechas por defecto
const obtenerFechasPorDefecto = () => {
  const hoy = new Date()
  const seisMesesAtras = new Date()
  seisMesesAtras.setMonth(seisMesesAtras.getMonth() - 6)

  return {
    fecha_desde: seisMesesAtras.toISOString().split('T')[0],
    fecha_hasta: hoy.toISOString().split('T')[0]
  }
}

// Filtros con fechas por defecto
const fechasDefault = obtenerFechasPorDefecto()
const filtros = ref({
  axo: null,
  folio: null,
  id_licencia: null,
  solicita: '',
  vigente: '',
  fecha_desde: fechasDefault.fecha_desde,
  fecha_hasta: fechasDefault.fecha_hasta
})

// Formularios
const formNuevo = ref({
  axo: new Date().getFullYear(),
  folio: null,
  id_licencia: null,
  solicita: '',
  partidapago: '',
  domicilio: '',
  tipo: null,
  observacion: '',
  capturista: 'sistema'
})

const formEditar = ref({
  axo: null,
  folio: null,
  id_licencia: null,
  solicita: '',
  partidapago: '',
  domicilio: '',
  tipo: null,
  observacion: ''
})

// Computed
const totalPages = computed(() => Math.ceil(totalResultados.value / itemsPerPage.value))

const visiblePages = computed(() => {
  const pages = []
  const maxVisible = 5
  let startPage = Math.max(1, currentPage.value - Math.floor(maxVisible / 2))
  let endPage = Math.min(totalPages.value, startPage + maxVisible - 1)

  if (endPage - startPage < maxVisible - 1) {
    startPage = Math.max(1, endPage - maxVisible + 1)
  }

  for (let i = startPage; i <= endPage; i++) {
    pages.push(i)
  }

  return pages
})

// Métodos
const toggleFilters = () => {
  showFilters.value = !showFilters.value
}

const cargarConstancias = async () => {
  showLoading('Cargando constancias...', 'Consultando base de datos')
  primeraBusqueda.value = true
  showFilters.value = false

  try {
    const params = [
      { nombre: 'p_axo', valor: filtros.value.axo || null, tipo: 'integer' },
      { nombre: 'p_folio', valor: filtros.value.folio || null, tipo: 'integer' },
      { nombre: 'p_id_licencia', valor: filtros.value.id_licencia || null, tipo: 'integer' },
      { nombre: 'p_solicita', valor: filtros.value.solicita || null, tipo: 'string' },
      { nombre: 'p_vigente', valor: filtros.value.vigente || null, tipo: 'string' },
      { nombre: 'p_fecha_desde', valor: filtros.value.fecha_desde || null, tipo: 'date' },
      { nombre: 'p_fecha_hasta', valor: filtros.value.fecha_hasta || null, tipo: 'date' },
      { nombre: 'p_page', valor: currentPage.value, tipo: 'integer' },
      { nombre: 'p_limit', valor: itemsPerPage.value, tipo: 'integer' }
    ]

    const response = await execute(
      'constancias_list',
      'padron_licencias',
      params,
      'padron_licencias',
      null,
      'public'
    )

    hideLoading()

    if (response && response.result) {
      constancias.value = response.result
      if (constancias.value.length > 0) {
        totalResultados.value = parseInt(constancias.value[0].total_records) || 0
      } else {
        totalResultados.value = 0
      }
    }
  } catch (error) {
    hideLoading()
    handleApiError(error)
  }
}

const buscarConstancias = () => {
  currentPage.value = 1
  showFilters.value = false
  cargarConstancias()
}

const cargarEstadisticas = async () => {
  try {
    const response = await execute(
      'constancias_estadisticas',
      'padron_licencias',
      [],
      'padron_licencias',
      null,
      'public'
    )

    if (response && response.result) {
      estadisticas.value = response.result
    }
  } catch (error) {
    console.error('Error al cargar estadísticas:', error)
  } finally {
    loadingEstadisticas.value = false
  }
}

const abrirModalNuevo = async () => {
  // Obtener siguiente folio disponible
  try {
    const response = await execute(
      'constancias_get_next_folio',
      'padron_licencias',
      [{ nombre: 'p_axo', valor: formNuevo.value.axo, tipo: 'integer' }],
      'padron_licencias',
      null,
      'public'
    )

    if (response && response.result && response.result.length > 0) {
      formNuevo.value.folio = response.result[0].next_folio
    }
  } catch (error) {
    console.error('Error al obtener siguiente folio:', error)
  }

  showModalNuevo.value = true
}

const cerrarModalNuevo = () => {
  showModalNuevo.value = false
  formNuevo.value = {
    axo: new Date().getFullYear(),
    folio: null,
    id_licencia: null,
    solicita: '',
    partidapago: '',
    domicilio: '',
    tipo: null,
    observacion: '',
    capturista: 'sistema'
  }
}

const crearConstancia = async () => {
  // Validar campos requeridos con mensajes específicos
  const errores = []

  if (!formNuevo.value.axo) {
    errores.push('• Año es requerido')
  }

  if (!formNuevo.value.folio) {
    errores.push('• Folio es requerido')
  }

  if (!formNuevo.value.id_licencia) {
    errores.push('• ID de Licencia es requerido')
  }

  if (!formNuevo.value.solicita || formNuevo.value.solicita.trim() === '') {
    errores.push('• Nombre del Solicitante es requerido')
  }

  // Si hay errores, mostrar modal con la lista de problemas
  if (errores.length > 0) {
    await Swal.fire({
      title: 'Campos requeridos incompletos',
      html: `
        <div style="text-align: left; padding: 0 1rem;">
          <p style="margin-bottom: 1rem; color: #6c757d;">Por favor complete los siguientes campos:</p>
          <ul style="color: #dc3545; font-weight: 500; line-height: 1.8;">
            ${errores.join('<br>')}
          </ul>
        </div>
      `,
      icon: 'warning',
      confirmButtonColor: '#ea8215',
      confirmButtonText: 'Entendido'
    })
    return
  }

  loadingModal.value = true
  showLoading('Creando constancia...', 'Guardando en base de datos')

  try {
    const params = [
      { nombre: 'p_axo', valor: formNuevo.value.axo, tipo: 'integer' },
      { nombre: 'p_folio', valor: formNuevo.value.folio, tipo: 'integer' },
      { nombre: 'p_id_licencia', valor: formNuevo.value.id_licencia, tipo: 'integer' },
      { nombre: 'p_solicita', valor: formNuevo.value.solicita.trim(), tipo: 'string' },
      { nombre: 'p_partidapago', valor: formNuevo.value.partidapago || null, tipo: 'string' },
      { nombre: 'p_domicilio', valor: formNuevo.value.domicilio || null, tipo: 'string' },
      { nombre: 'p_tipo', valor: formNuevo.value.tipo || null, tipo: 'smallint' },
      { nombre: 'p_observacion', valor: formNuevo.value.observacion || null, tipo: 'string' },
      { nombre: 'p_capturista', valor: formNuevo.value.capturista, tipo: 'string' }
    ]

    const response = await execute(
      'constancias_create',
      'padron_licencias',
      params,
      'padron_licencias',
      null,
      'public'
    )

    hideLoading()

    if (response && response.result && response.result.length > 0) {
      const result = response.result[0]
      if (result.success) {
        await Swal.fire({
          title: 'Éxito',
          text: result.message,
          icon: 'success',
          confirmButtonColor: '#ea8215'
        })
        cerrarModalNuevo()
        cargarConstancias()
        cargarEstadisticas()
      } else {
        // Mostrar error específico de la base de datos
        await Swal.fire({
          title: 'Error al crear',
          text: result.message || 'No se pudo crear la constancia. Verifique los datos e intente nuevamente.',
          icon: 'error',
          confirmButtonColor: '#dc3545'
        })
      }
    } else {
      // Error si no hay respuesta
      await Swal.fire({
        title: 'Error de Comunicación',
        text: 'No se recibió respuesta del servidor. Por favor intente nuevamente.',
        icon: 'error',
        confirmButtonColor: '#dc3545'
      })
    }
  } catch (error) {
    hideLoading()
    // Mejorar el manejo de errores
    await Swal.fire({
      title: 'Error Inesperado',
      html: `
        <div style="text-align: left; padding: 0 1rem;">
          <p style="margin-bottom: 0.5rem; color: #6c757d;">Ocurrió un error al crear la constancia:</p>
          <p style="color: #dc3545; font-weight: 500;">${error.message || 'Error desconocido'}</p>
          <p style="margin-top: 1rem; color: #6c757d; font-size: 0.9rem;">Si el problema persiste, contacte al administrador del sistema.</p>
        </div>
      `,
      icon: 'error',
      confirmButtonColor: '#dc3545'
    })
  } finally {
    loadingModal.value = false
  }
}

const editarConstancia = (constancia) => {
  formEditar.value = {
    axo: constancia.axo,
    folio: constancia.folio,
    id_licencia: constancia.id_licencia,
    solicita: constancia.solicita,
    partidapago: constancia.partidapago,
    domicilio: constancia.domicilio,
    tipo: constancia.tipo,
    observacion: constancia.observacion
  }
  showModalEditar.value = true
}

const cerrarModalEditar = () => {
  showModalEditar.value = false
  formEditar.value = {
    axo: null,
    folio: null,
    id_licencia: null,
    solicita: '',
    partidapago: '',
    domicilio: '',
    tipo: null,
    observacion: ''
  }
}

const actualizarConstancia = async () => {
  // Validar campos requeridos con mensajes específicos
  const errores = []

  if (!formEditar.value.axo) {
    errores.push('• Año es requerido')
  }

  if (!formEditar.value.folio) {
    errores.push('• Folio es requerido')
  }

  if (!formEditar.value.id_licencia) {
    errores.push('• ID de Licencia es requerido')
  }

  if (!formEditar.value.solicita || formEditar.value.solicita.trim() === '') {
    errores.push('• Nombre del Solicitante es requerido')
  }

  // Si hay errores, mostrar modal con la lista de problemas
  if (errores.length > 0) {
    await Swal.fire({
      title: 'Campos requeridos incompletos',
      html: `
        <div style="text-align: left; padding: 0 1rem;">
          <p style="margin-bottom: 1rem; color: #6c757d;">Por favor complete los siguientes campos:</p>
          <ul style="color: #dc3545; font-weight: 500; line-height: 1.8;">
            ${errores.join('<br>')}
          </ul>
        </div>
      `,
      icon: 'warning',
      confirmButtonColor: '#ea8215',
      confirmButtonText: 'Entendido'
    })
    return
  }

  loadingModal.value = true
  showLoading('Actualizando constancia...', 'Guardando cambios')

  try {
    const params = [
      { nombre: 'p_axo', valor: formEditar.value.axo, tipo: 'integer' },
      { nombre: 'p_folio', valor: formEditar.value.folio, tipo: 'integer' },
      { nombre: 'p_id_licencia', valor: formEditar.value.id_licencia, tipo: 'integer' },
      { nombre: 'p_solicita', valor: formEditar.value.solicita.trim(), tipo: 'string' },
      { nombre: 'p_partidapago', valor: formEditar.value.partidapago || null, tipo: 'string' },
      { nombre: 'p_domicilio', valor: formEditar.value.domicilio || null, tipo: 'string' },
      { nombre: 'p_tipo', valor: formEditar.value.tipo || null, tipo: 'smallint' },
      { nombre: 'p_observacion', valor: formEditar.value.observacion || null, tipo: 'string' }
    ]

    const response = await execute(
      'constancias_update',
      'padron_licencias',
      params,
      'padron_licencias',
      null,
      'public'
    )

    hideLoading()

    if (response && response.result && response.result.length > 0) {
      const result = response.result[0]
      if (result.success) {
        await Swal.fire({
          title: 'Éxito',
          text: result.message,
          icon: 'success',
          confirmButtonColor: '#ea8215'
        })
        cerrarModalEditar()
        cargarConstancias()
      } else {
        // Mostrar error específico de la base de datos
        await Swal.fire({
          title: 'Error al actualizar',
          text: result.message || 'No se pudo actualizar la constancia. Verifique los datos e intente nuevamente.',
          icon: 'error',
          confirmButtonColor: '#dc3545'
        })
      }
    } else {
      // Error si no hay respuesta
      await Swal.fire({
        title: 'Error de Comunicación',
        text: 'No se recibió respuesta del servidor. Por favor intente nuevamente.',
        icon: 'error',
        confirmButtonColor: '#dc3545'
      })
    }
  } catch (error) {
    hideLoading()
    // Mejorar el manejo de errores
    await Swal.fire({
      title: 'Error Inesperado',
      html: `
        <div style="text-align: left; padding: 0 1rem;">
          <p style="margin-bottom: 0.5rem; color: #6c757d;">Ocurrió un error al actualizar la constancia:</p>
          <p style="color: #dc3545; font-weight: 500;">${error.message || 'Error desconocido'}</p>
          <p style="margin-top: 1rem; color: #6c757d; font-size: 0.9rem;">Si el problema persiste, contacte al administrador del sistema.</p>
        </div>
      `,
      icon: 'error',
      confirmButtonColor: '#dc3545'
    })
  } finally {
    loadingModal.value = false
  }
}

const confirmarEliminar = async (constancia) => {
  const result = await Swal.fire({
    title: '¿Cancelar constancia?',
    text: `¿Estás seguro de cancelar la constancia ${constancia.axo}/${constancia.folio}? Esta acción no se puede deshacer.`,
    icon: 'warning',
    showCancelButton: true,
    confirmButtonColor: '#d33',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, cancelar',
    cancelButtonText: 'No, mantener'
  })

  if (result.isConfirmed) {
    await eliminarConstancia(constancia)
  }
}

const eliminarConstancia = async (constancia) => {
  showLoading('Cancelando constancia...', 'Actualizando base de datos')

  try {
    const params = [
      { nombre: 'p_axo', valor: constancia.axo, tipo: 'integer' },
      { nombre: 'p_folio', valor: constancia.folio, tipo: 'integer' }
    ]

    const response = await execute(
      'constancias_delete',
      'padron_licencias',
      params,
      'padron_licencias',
      null,
      'public'
    )

    hideLoading()

    if (response && response.result && response.result.length > 0) {
      const result = response.result[0]
      if (result.success) {
        await Swal.fire({
          title: 'Cancelada',
          text: result.message,
          icon: 'success',
          confirmButtonColor: '#ea8215'
        })
        cargarConstancias()
        cargarEstadisticas()
      } else {
        showToast(result.message, 'error')
      }
    }
  } catch (error) {
    hideLoading()
    handleApiError(error)
  }
}

const verDetalle = (constancia) => {
  constanciaSeleccionada.value = constancia
  showDetalleModal.value = true
}

const goToPage = (page) => {
  if (page !== '...' && page >= 1 && page <= totalPages.value) {
    currentPage.value = page
    cargarConstancias()
  }
}

const changePageSize = () => {
  currentPage.value = 1
  cargarConstancias()
}

// Utilidades
const getVigenteIcon = (vigente) => {
  const icons = {
    'V': 'check-circle',
    'C': 'ban'
  }
  return icons[vigente] || 'question-circle'
}

const getVigenteDesc = (vigente) => {
  const desc = {
    'V': 'Vigente',
    'C': 'Cancelado'
  }
  return desc[vigente] || vigente
}

const formatDate = (dateString) => {
  if (!dateString) return 'N/A'
  try {
    const date = new Date(dateString)
    return date.toLocaleDateString('es-ES', {
      year: 'numeric',
      month: '2-digit',
      day: '2-digit'
    })
  } catch {
    return 'N/A'
  }
}

const formatNumber = (num) => {
  return new Intl.NumberFormat('es-MX').format(num)
}

// Watch
watch(() => formNuevo.value.axo, async (newAxo) => {
  if (newAxo && showModalNuevo.value) {
    try {
      const response = await execute(
        'constancias_get_next_folio',
        'padron_licencias',
        [{ nombre: 'p_axo', valor: newAxo, tipo: 'integer' }],
        'padron_licencias',
        null,
        'public'
      )

      if (response && response.result && response.result.length > 0) {
        formNuevo.value.folio = response.result[0].next_folio
      }
    } catch (error) {
      console.error('Error al obtener siguiente folio:', error)
    }
  }
})

// Lifecycle
onMounted(() => {
  cargarEstadisticas()
  // NO cargar constancias automáticamente
  // El usuario debe hacer clic en "Actualizar" o "Buscar"
})
</script>

<style scoped>
.header-with-badge {
  display: flex;
  align-items: center;
  justify-content: space-between;
  width: 100%;
}

.badge-purple {
  background: linear-gradient(135deg, #9264cc 0%, #7c4dbd 100%);
  color: white;
  padding: 0.5rem 1rem;
  border-radius: 20px;
  font-size: 0.85rem;
  font-weight: 600;
  box-shadow: 0 2px 8px rgba(146, 100, 204, 0.3);
}

.required {
  color: #dc3545;
  font-weight: bold;
  margin-left: 2px;
}

/* ========================================
   MODALES MÁS ANCHOS Y MEJOR ORGANIZADOS
   ======================================== */

/* Modal de detalle - Extra ancho */
:deep(.modal-constancia-detalle .modal-dialog) {
  max-width: 95% !important;
  width: 1400px !important;
}

/* Modales de formulario - Extra anchos */
:deep(.modal-constancia-form .modal-dialog) {
  max-width: 90% !important;
  width: 1200px !important;
}

/* Secciones del formulario */
.form-section {
  background: #f8f9fa;
  border: 1px solid #e8e8e8;
  border-radius: 8px;
  padding: 1.5rem;
  margin-bottom: 1.5rem;
}

.form-section-title {
  color: #ea8215;
  font-size: 1rem;
  font-weight: 600;
  margin-bottom: 1.25rem;
  padding-bottom: 0.75rem;
  border-bottom: 2px solid #ea8215;
  display: flex;
  align-items: center;
}

/* Form rows mejorados */
.form-row {
  display: flex;
  gap: 1.5rem;
  margin-bottom: 1rem;
}

.form-row:last-child {
  margin-bottom: 0;
}

.form-group {
  flex: 1;
  display: flex;
  flex-direction: column;
}

.form-group.col-3 {
  flex: 0 0 calc(25% - 1.125rem);
}

.form-group.col-4 {
  flex: 0 0 calc(33.333% - 1rem);
}

.form-group.col-6 {
  flex: 0 0 calc(50% - 0.75rem);
}

.form-group.full-width {
  flex: 1 1 100%;
}

.municipal-form-label {
  font-weight: 600;
  color: #495057;
  margin-bottom: 0.5rem;
  font-size: 0.95rem;
}

.municipal-form-control {
  padding: 0.75rem;
  font-size: 0.95rem;
  border: 1px solid #ced4da;
  border-radius: 6px;
  transition: all 0.3s ease;
}

.municipal-form-control:focus {
  border-color: #ea8215;
  box-shadow: 0 0 0 0.2rem rgba(234, 130, 21, 0.15);
  outline: none;
}

.municipal-form-control:disabled {
  background-color: #e9ecef;
  cursor: not-allowed;
}

.municipal-form-control[readonly] {
  background-color: #f8f9fa;
  color: #6c757d;
  font-style: italic;
}

textarea.municipal-form-control {
  resize: vertical;
  min-height: 100px;
}

/* Modal actions */
.modal-actions {
  display: flex;
  justify-content: flex-end;
  gap: 1rem;
  margin-top: 2rem;
  padding-top: 1.5rem;
  border-top: 2px solid #e8e8e8;
}

/* ========================================
   ESTILOS DE TABLA - AÑO, FOLIO Y LICENCIA
   ======================================== */

/* Contenedor de folio mejorado */
.folio-display {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  min-width: 80px;
}

/* Año destacado */
.folio-year {
  background: linear-gradient(135deg, #ea8215 0%, #d67512 100%);
  color: white;
  padding: 0.35rem 0.75rem;
  border-radius: 6px;
  font-weight: 600;
  font-size: 0.85rem;
  box-shadow: 0 2px 6px rgba(234, 130, 21, 0.2);
  letter-spacing: 0.3px;
  display: inline-block;
  min-width: 60px;
  text-align: center;
  transition: all 0.3s ease;
}

.folio-year:hover {
  transform: translateY(-1px);
  box-shadow: 0 3px 8px rgba(234, 130, 21, 0.3);
}

/* Folio destacado */
.folio-number {
  background: linear-gradient(135deg, #9264cc 0%, #7c4dbd 100%);
  color: white;
  padding: 0.35rem 0.75rem;
  border-radius: 6px;
  font-weight: 600;
  font-size: 0.85rem;
  box-shadow: 0 2px 6px rgba(146, 100, 204, 0.2);
  letter-spacing: 0.3px;
  display: inline-block;
  min-width: 65px;
  text-align: center;
  transition: all 0.3s ease;
}

.folio-number:hover {
  transform: translateY(-1px);
  box-shadow: 0 3px 8px rgba(146, 100, 204, 0.3);
}

/* Contenedor de badge de licencia */
.licencia-badge-container {
  display: flex;
  align-items: center;
  justify-content: center;
  min-height: 32px;
}

/* Badge de licencia mejorado */
.licencia-badge {
  padding: 0.35rem 0.75rem;
  border-radius: 5px;
  font-weight: 600;
  font-size: 0.8rem;
  display: inline-flex;
  align-items: center;
  gap: 0.4rem;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.08);
  transition: all 0.3s ease;
  min-width: 120px;
  justify-content: center;
}

.licencia-badge:hover {
  transform: translateY(-1px);
  box-shadow: 0 3px 8px rgba(0, 0, 0, 0.12);
}

/* Badge info (con licencia) */
.badge.badge-purple.licencia-badge {
  background: linear-gradient(135deg, #17a2b8 0%, #138496 100%);
  color: white;
}

/* Badge secondary (sin licencia) */
.badge.badge-secondary.licencia-badge {
  background: linear-gradient(135deg, #6c757d 0%, #5a6268 100%);
  color: white;
  font-style: italic;
}

/* Responsive para modales */
@media (max-width: 1400px) {
  :deep(.modal-constancia-detalle .modal-dialog) {
    width: 95% !important;
  }

  :deep(.modal-constancia-form .modal-dialog) {
    width: 90% !important;
  }
}

@media (max-width: 992px) {
  .form-row {
    flex-direction: column;
    gap: 1rem;
  }

  .form-group.col-3,
  .form-group.col-4,
  .form-group.col-6 {
    flex: 1 1 100%;
  }

  :deep(.modal-constancia-form .modal-dialog),
  :deep(.modal-constancia-detalle .modal-dialog) {
    width: 95% !important;
    max-width: 95% !important;
  }

  .folio-year,
  .folio-number {
    min-width: 55px;
    padding: 0.3rem 0.6rem;
    font-size: 0.8rem;
  }

  .licencia-badge {
    min-width: 110px;
    font-size: 0.75rem;
  }
}
</style>
