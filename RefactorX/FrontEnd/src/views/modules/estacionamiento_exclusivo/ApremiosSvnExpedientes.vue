<template>
  <div class="module-view module-layout">
    <!-- ========== HEADER ========== -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="folder-open" />
      </div>
      <div class="module-view-info">
        <h1>Expedientes de Apremios</h1>
        <p>Gestión y consulta de expedientes de cobranza coactiva - ta_15_apremios</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-info" @click="abrirDocumentacion">
          <font-awesome-icon icon="book" />
          Documentación
        </button>
        <button class="btn-municipal-purple" @click="abrirAyuda">
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
        <button class="btn-municipal-secondary" @click="toggleFilters">
          <font-awesome-icon :icon="showFilters ? 'chevron-up' : 'filter'" />
          Filtros
        </button>
        <button class="btn-municipal-primary" @click="buscar">
          <font-awesome-icon icon="sync-alt" />
          Actualizar
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <!-- ========== ESTADÍSTICAS ========== -->
      <div class="stats-grid" v-if="loadingEstadisticas">
        <div class="stat-card stat-card-loading" v-for="n in 6" :key="`loading-${n}`">
          <div class="stat-content">
            <div class="skeleton-icon"></div>
            <div class="skeleton-number"></div>
            <div class="skeleton-label"></div>
          </div>
        </div>
      </div>

      <div class="stats-grid" v-else-if="estadisticas.length > 0">
        <div
          class="stat-card"
          v-for="stat in estadisticas"
          :key="stat.categoria"
          :class="`stat-${stat.clase}`"
          @click="filtrarPorCategoria(stat.categoria)"
          style="cursor: pointer;"
        >
          <div class="stat-content">
            <div class="stat-icon">
              <font-awesome-icon :icon="getStatIcon(stat.categoria)" />
            </div>
            <h3 class="stat-number">{{ formatNumber(stat.total) }}</h3>
            <p class="stat-label">{{ stat.descripcion }}</p>
            <small class="stat-percentage" v-if="stat.porcentaje > 0">{{ Number(stat.porcentaje).toFixed(1) }}%</small>
          </div>
        </div>
      </div>

      <!-- ========== FILTROS ========== -->
      <div class="municipal-card" v-show="showFilters">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="filter" /> Filtros de Búsqueda</h5>
        </div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Zona/Recaudadora</label>
              <select class="municipal-form-control" v-model="filters.zona">
                <option :value="null">Todas</option>
                <option :value="1">1 - Zona Centro</option>
                <option :value="2">2 - Zona Norte</option>
                <option :value="3">3 - Zona Sur</option>
                <option :value="4">4 - Zona Oriente</option>
                <option :value="5">5 - Zona Poniente</option>
              </select>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Módulo/Aplicación</label>
              <select class="municipal-form-control" v-model="filters.modulo">
                <option :value="null">Todos</option>
                <option :value="5">5 - Aseo Contratado</option>
                <option :value="9">9 - Mercados</option>
                <option :value="11">11 - Est. Públicos</option>
                <option :value="16">16 - Est. Exclusivos</option>
                <option :value="17">17 - Infracciones</option>
              </select>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Vigencia</label>
              <select class="municipal-form-control" v-model="filters.vigencia">
                <option :value="null">Todas</option>
                <option value="1">Vigente</option>
                <option value="2">Pagado</option>
                <option value="P">Pago Parcial</option>
                <option value="3">Cancelado</option>
              </select>
            </div>
          </div>
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Fecha Desde</label>
              <input type="date" class="municipal-form-control" v-model="filters.fechaDesde" />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Fecha Hasta</label>
              <input type="date" class="municipal-form-control" v-model="filters.fechaHasta" />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Ejecutor (Clave)</label>
              <input
                type="number"
                class="municipal-form-control"
                v-model.number="filters.ejecutor"
                placeholder="Ej: 101"
              />
            </div>
          </div>
          <div class="button-group">
            <button class="btn-municipal-primary" @click="buscar">
              <font-awesome-icon icon="search" />
              Buscar
            </button>
            <button class="btn-municipal-secondary" @click="limpiarFiltros">
              <font-awesome-icon icon="eraser" />
              Limpiar
            </button>
          </div>
        </div>
      </div>

      <!-- ========== TABLA DE RESULTADOS ========== -->
      <div class="municipal-card">
        <div class="municipal-card-header header-with-badge">
          <h5>
            <font-awesome-icon icon="list" />
            Expedientes de Apremios
          </h5>
          <div class="header-right">
            <span class="badge-purple" v-if="rows.length > 0">
              {{ formatNumber(totalResultados) }} registros
            </span>
          </div>
        </div>

        <div class="municipal-card-body table-container">
          <!-- Empty State - Sin búsqueda -->
          <div v-if="rows.length === 0 && !hasSearched" class="empty-state">
            <div class="empty-state-icon">
              <font-awesome-icon icon="folder-open" size="3x" />
            </div>
            <h4>Expedientes de Apremios</h4>
            <p>Utiliza los filtros o haz clic en Actualizar para cargar expedientes</p>
          </div>

          <!-- Empty State - Sin resultados -->
          <div v-else-if="rows.length === 0 && hasSearched" class="empty-state">
            <div class="empty-state-icon">
              <font-awesome-icon icon="inbox" size="3x" />
            </div>
            <h4>Sin resultados</h4>
            <p>No se encontraron expedientes con los criterios especificados</p>
          </div>

          <!-- Tabla de datos -->
          <div v-else class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Expediente</th>
                  <th>Folio</th>
                  <th>Zona</th>
                  <th>Módulo</th>
                  <th>Fecha Emisión</th>
                  <th class="text-end">Importe</th>
                  <th class="text-end">Pagado</th>
                  <th class="text-end">Saldo</th>
                  <th>Vigencia</th>
                  <th>Ejecutor</th>
                  <th class="text-center">Acciones</th>
                </tr>
              </thead>
              <tbody>
                <tr
                  v-for="(r, idx) in paginatedRows"
                  :key="idx"
                  @click="selectedRow = r"
                  :class="{ 'table-row-selected': selectedRow === r }"
                  class="row-hover"
                >
                  <td><strong>{{ r.expediente }}</strong></td>
                  <td><code>{{ r.folio }}</code></td>
                  <td>{{ r.zona }}</td>
                  <td>{{ getModuloNombre(r.modulo) }}</td>
                  <td>{{ formatDate(r.fecha_emision) }}</td>
                  <td class="text-end">{{ formatMoney(r.importe_global) }}</td>
                  <td class="text-end">{{ formatMoney(r.importe_pago) }}</td>
                  <td class="text-end" :class="getSaldoClass(r.saldo)">
                    <strong>{{ formatMoney(r.saldo) }}</strong>
                  </td>
                  <td>
                    <span class="badge" :class="getVigenciaBadgeClass(r.vigencia)">
                      {{ r.vigencia }}
                    </span>
                  </td>
                  <td>{{ r.ejecutor_nombre || '-' }}</td>
                  <td class="text-center">
                    <div class="button-group button-group-sm">
                      <button class="btn-municipal-info btn-sm" @click.stop="verDetalle(r)" title="Ver detalle">
                        <font-awesome-icon icon="eye" />
                      </button>
                      <button class="btn-municipal-warning btn-sm" @click.stop="verHistorial(r)" title="Historial">
                        <font-awesome-icon icon="history" />
                      </button>
                    </div>
                  </td>
                </tr>
              </tbody>
              <tfoot v-if="rows.length > 0">
                <tr class="municipal-table-footer">
                  <td colspan="5" class="text-end"><strong>Totales:</strong></td>
                  <td class="text-end"><strong>{{ formatMoney(totalImportes) }}</strong></td>
                  <td class="text-end"><strong>{{ formatMoney(totalPagado) }}</strong></td>
                  <td class="text-end"><strong>{{ formatMoney(totalSaldo) }}</strong></td>
                  <td colspan="3"></td>
                </tr>
              </tfoot>
            </table>
          </div>

          <!-- Paginación -->
          <div v-if="rows.length > 0" class="pagination-controls">
            <div class="pagination-info">
              <span class="text-muted">
                Mostrando {{ ((currentPage - 1) * itemsPerPage) + 1 }}
                a {{ Math.min(currentPage * itemsPerPage, totalResultados) }}
                de {{ formatNumber(totalResultados) }} registros
              </span>
            </div>
            <div class="pagination-size">
              <label class="municipal-form-label me-2">Registros por página:</label>
              <select
                class="municipal-form-control form-control-sm"
                :value="itemsPerPage"
                @change="changePageSize($event.target.value)"
                style="width: auto; display: inline-block;"
              >
                <option value="5">5</option>
                <option value="10">10</option>
                <option value="25">25</option>
                <option value="50">50</option>
                <option value="100">100</option>
              </select>
            </div>
            <div class="pagination-buttons">
              <button class="btn-municipal-secondary btn-sm" @click="goToPage(1)" :disabled="currentPage === 1">
                <font-awesome-icon icon="angle-double-left" />
              </button>
              <button class="btn-municipal-secondary btn-sm" @click="goToPage(currentPage - 1)" :disabled="currentPage === 1">
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
              <button class="btn-municipal-secondary btn-sm" @click="goToPage(currentPage + 1)" :disabled="currentPage === totalPages">
                <font-awesome-icon icon="angle-right" />
              </button>
              <button class="btn-municipal-secondary btn-sm" @click="goToPage(totalPages)" :disabled="currentPage === totalPages">
                <font-awesome-icon icon="angle-double-right" />
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- ========== MODAL DETALLE ========== -->
      <Modal
        :show="showDetail"
        :title="`Expediente #${selected?.expediente || ''}`"
        size="xl"
        @close="showDetail = false"
        :showDefaultFooter="false"
      >
        <div v-if="selected" class="tramite-details">
          <!-- Header con estado destacado -->
          <div class="expediente-header">
            <div class="expediente-info">
              <span class="expediente-badge">
                <font-awesome-icon icon="folder-open" />
                {{ selected.expediente }}
              </span>
              <span class="badge badge-lg" :class="getVigenciaBadgeClass(selected.vigencia)">
                <font-awesome-icon :icon="getVigenciaIcon(selected.vigencia)" />
                {{ selected.vigencia }}
              </span>
            </div>
            <div class="expediente-saldo" :class="selected.saldo > 0 ? 'saldo-pendiente' : 'saldo-pagado'">
              <small>Saldo Pendiente</small>
              <strong>{{ formatMoney(selected.saldo) }}</strong>
            </div>
          </div>

          <div class="details-grid">
            <!-- Información General -->
            <div class="detail-section">
              <h6 class="section-title">
                <font-awesome-icon icon="info-circle" />
                Información General
              </h6>
              <table class="detail-table">
                <tr>
                  <td class="label">Folio:</td>
                  <td><strong class="text-primary">{{ selected.folio }}</strong></td>
                </tr>
                <tr>
                  <td class="label">Zona:</td>
                  <td>
                    <span class="badge badge-secondary">{{ selected.zona }}</span>
                  </td>
                </tr>
                <tr>
                  <td class="label">Módulo:</td>
                  <td>
                    <font-awesome-icon icon="cubes" class="text-muted" />
                    {{ getModuloNombre(selected.modulo) }}
                  </td>
                </tr>
                <tr>
                  <td class="label">Fecha Emisión:</td>
                  <td>
                    <font-awesome-icon icon="calendar-plus" class="text-success" />
                    {{ formatDate(selected.fecha_emision) }}
                  </td>
                </tr>
                <tr>
                  <td class="label">Fecha Practicado:</td>
                  <td>
                    <font-awesome-icon icon="calendar-check" :class="selected.fecha_practicado ? 'text-info' : 'text-muted'" />
                    {{ formatDate(selected.fecha_practicado) || 'Pendiente' }}
                  </td>
                </tr>
                <tr>
                  <td class="label">Clave Practicado:</td>
                  <td>
                    <span class="badge" :class="getClavePracticadoBadge(selected.clave_practicado)">
                      {{ getClavePracticado(selected.clave_practicado) }}
                    </span>
                  </td>
                </tr>
              </table>
            </div>

            <!-- Importes -->
            <div class="detail-section">
              <h6 class="section-title">
                <font-awesome-icon icon="coins" />
                Importes y Saldos
              </h6>
              <table class="detail-table">
                <tr>
                  <td class="label">Importe Global:</td>
                  <td>
                    <strong class="text-primary">{{ formatMoney(selected.importe_global) }}</strong>
                  </td>
                </tr>
                <tr>
                  <td class="label">Importe Pagado:</td>
                  <td>
                    <font-awesome-icon icon="check-circle" class="text-success" />
                    <strong class="text-success">{{ formatMoney(selected.importe_pago) }}</strong>
                  </td>
                </tr>
                <tr>
                  <td class="label">Saldo Pendiente:</td>
                  <td>
                    <font-awesome-icon :icon="selected.saldo > 0 ? 'exclamation-triangle' : 'check-double'" :class="selected.saldo > 0 ? 'text-danger' : 'text-success'" />
                    <strong :class="selected.saldo > 0 ? 'text-danger' : 'text-success'">{{ formatMoney(selected.saldo) }}</strong>
                  </td>
                </tr>
              </table>

              <!-- Barra de progreso de pago -->
              <div class="progress-container mt-3">
                <div class="progress-label">
                  <span>Avance de Pago</span>
                  <span>{{ getPorcentajePago(selected) }}%</span>
                </div>
                <div class="progress-bar-container">
                  <div class="progress-bar-fill" :style="{ width: getPorcentajePago(selected) + '%' }" :class="getPorcentajePago(selected) >= 100 ? 'bg-success' : 'bg-primary'"></div>
                </div>
              </div>
            </div>

            <!-- Ejecutor -->
            <div class="detail-section">
              <h6 class="section-title">
                <font-awesome-icon icon="user-tie" />
                Ejecutor Asignado
              </h6>
              <table class="detail-table">
                <tr>
                  <td class="label">Nombre:</td>
                  <td>
                    <font-awesome-icon :icon="selected.ejecutor_nombre ? 'user-check' : 'user-times'" :class="selected.ejecutor_nombre ? 'text-success' : 'text-muted'" />
                    {{ selected.ejecutor_nombre || 'Sin asignar' }}
                  </td>
                </tr>
              </table>
            </div>

            <!-- Vigencia -->
            <div class="detail-section">
              <h6 class="section-title">
                <font-awesome-icon icon="clock" />
                Estado del Expediente
              </h6>
              <div class="estado-expediente">
                <div class="estado-icon" :class="getVigenciaClass(selected.vigencia)">
                  <font-awesome-icon :icon="getVigenciaIcon(selected.vigencia)" size="2x" />
                </div>
                <div class="estado-info">
                  <strong>{{ selected.vigencia }}</strong>
                  <small>{{ getVigenciaDescripcion(selected.vigencia) }}</small>
                </div>
              </div>
            </div>
          </div>

          <!-- Datos Adicionales -->
          <div class="detail-section full-width" v-if="selected.datos || selected.observaciones">
            <h6 class="section-title">
              <font-awesome-icon icon="sticky-note" />
              Datos Adicionales
            </h6>
            <div class="datos-adicionales">
              <div v-if="selected.datos" class="dato-item">
                <label><font-awesome-icon icon="database" /> Datos:</label>
                <p>{{ selected.datos }}</p>
              </div>
              <div v-if="selected.observaciones" class="dato-item">
                <label><font-awesome-icon icon="comment-alt" /> Observaciones:</label>
                <p>{{ selected.observaciones }}</p>
              </div>
            </div>
          </div>

          <!-- Footer con acciones -->
          <div class="modal-actions">
            <button class="btn-municipal-secondary" @click="showDetail = false">
              <font-awesome-icon icon="times" /> Cerrar
            </button>
            <button class="btn-municipal-warning" @click="verHistorial(selected)">
              <font-awesome-icon icon="history" /> Ver Historial
            </button>
            <button class="btn-municipal-primary" @click="irAModificar">
              <font-awesome-icon icon="edit" /> Modificar Expediente
            </button>
          </div>
        </div>
      </Modal>

      <!-- ========== MODAL HISTORIAL ========== -->
      <Modal :show="showHistorial" title="Historial del Expediente" @close="showHistorial = false" size="xl" :showDefaultFooter="false">
        <div v-if="selected" class="historial-container">
          <!-- Header del expediente -->
          <div class="historial-header">
            <div class="historial-expediente-info">
              <span class="expediente-badge">
                <font-awesome-icon icon="folder-open" />
                {{ selected.expediente }}
              </span>
              <span class="historial-folio">Folio: <strong>{{ selected.folio }}</strong></span>
            </div>
            <div class="historial-resumen">
              <div class="resumen-item">
                <font-awesome-icon icon="list-ol" class="text-primary" />
                <span>{{ historial.length }} movimiento(s)</span>
              </div>
              <div class="resumen-item">
                <font-awesome-icon icon="coins" class="text-warning" />
                <span>{{ formatMoney(selected.importe_global) }}</span>
              </div>
            </div>
          </div>

          <!-- Loading -->
          <div v-if="historialLoading" class="historial-loading">
            <div class="spinner-border" role="status"></div>
            <p>Cargando historial de movimientos...</p>
          </div>

          <!-- Sin historial -->
          <div v-else-if="historial.length === 0" class="empty-state">
            <font-awesome-icon icon="history" size="3x" class="empty-icon" />
            <h5>Sin historial disponible</h5>
            <p>Este expediente no tiene movimientos registrados</p>
          </div>

          <!-- Timeline de historial -->
          <div v-else class="historial-timeline">
            <div
              v-for="(h, i) in historial"
              :key="i"
              class="timeline-item"
              :class="getTimelineClass(h.clave_mov)"
            >
              <div class="timeline-marker">
                <font-awesome-icon :icon="getMovimientoIcon(h.clave_mov)" />
              </div>
              <div class="timeline-content">
                <div class="timeline-header">
                  <span class="timeline-badge" :class="getMovimientoBadgeClass(h.clave_mov)">
                    {{ h.clave_mov || 'MOV' }}
                  </span>
                  <span class="timeline-descripcion">{{ getMovimientoDescripcion(h.clave_mov) }}</span>
                  <span class="timeline-fecha">
                    <font-awesome-icon icon="calendar-alt" />
                    {{ formatDate(h.fecha_actualiz) }}
                  </span>
                </div>
                <div class="timeline-body">
                  <div class="timeline-details">
                    <div class="detail-row" v-if="h.diligencia">
                      <span class="detail-label">Diligencia:</span>
                      <span class="detail-value">
                        <span class="badge" :class="getDiligenciaBadge(h.diligencia)">
                          {{ getDiligenciaDescripcion(h.diligencia) }}
                        </span>
                      </span>
                    </div>
                    <div class="detail-row" v-if="h.vigencia">
                      <span class="detail-label">Vigencia:</span>
                      <span class="detail-value">{{ getVigenciaTexto(h.vigencia) }}</span>
                    </div>
                    <div class="detail-row" v-if="h.importe_global">
                      <span class="detail-label">Importe:</span>
                      <span class="detail-value text-primary">{{ formatMoney(h.importe_global) }}</span>
                    </div>
                    <div class="detail-row" v-if="h.importe_pago">
                      <span class="detail-label">Pagado:</span>
                      <span class="detail-value text-success">{{ formatMoney(h.importe_pago) }}</span>
                    </div>
                    <div class="detail-row" v-if="h.ejecutor || h.nombre_eje">
                      <span class="detail-label">Ejecutor:</span>
                      <span class="detail-value">{{ h.nombre_eje || `Clave ${h.ejecutor}` }}</span>
                    </div>
                    <div class="detail-row" v-if="h.fecha_practicado">
                      <span class="detail-label">Practicado:</span>
                      <span class="detail-value">{{ formatDate(h.fecha_practicado) }}</span>
                    </div>
                  </div>
                  <div class="timeline-observaciones" v-if="h.observaciones">
                    <font-awesome-icon icon="comment-alt" />
                    {{ h.observaciones }}
                  </div>
                </div>
                <div class="timeline-footer">
                  <span class="timeline-usuario">
                    <font-awesome-icon icon="user" />
                    {{ h.usu_descrip || `Usuario #${h.usuario}` }}
                  </span>
                </div>
              </div>
            </div>
          </div>

          <!-- Footer -->
          <div class="modal-actions">
            <button class="btn-municipal-secondary" @click="exportarHistorial" v-if="historial.length > 0">
              <font-awesome-icon icon="file-excel" /> Exportar
            </button>
            <button class="btn-municipal-primary" @click="showHistorial = false">
              <font-awesome-icon icon="times" /> Cerrar
            </button>
          </div>
        </div>
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

      <!-- Modal de Ayuda y Documentación -->
      <DocumentationModal
        :show="showDocModal"
        :componentName="'ApremiosSvnExpedientes'"
        :moduleName="'estacionamiento_exclusivo'"
        :docType="docType"
        :title="'Expedientes de Apremios'"
        @close="showDocModal = false"
      />
    </div>
    <!-- /module-view-content -->
  </div>
  <!-- /module-view -->
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import Modal from '@/components/common/Modal.vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useGlobalLoading } from '@/composables/useGlobalLoading'

// ========== CONSTANTES ==========
const BASE_DB = 'estacionamiento_exclusivo'
const OP_LIST = 'apremiossvn_expedientes_list'
const OP_STATS = 'apremiossvn_expedientes_estadisticas'
const OP_HISTORIAL = 'sp_get_cons_his'  // SP completo con descripciones

// Mapeo de módulos según sistema original
const MODULOS = {
  5: 'Aseo Contratado',
  9: 'Mercados',
  11: 'Est. Públicos',
  16: 'Est. Exclusivos',
  17: 'Infracciones',
  400: 'Módulo 400'
}

// ========== COMPOSABLES ==========
const router = useRouter()
const { execute } = useApi()
const {
  toast,
  showToast,
  hideToast,
  getToastIcon,
  handleApiError
} = useLicenciasErrorHandler()

const { showLoading, hideLoading } = useGlobalLoading()

// ========== ESTADO - FILTROS ==========
const showFilters = ref(true)
const filters = ref({
  zona: null,
  modulo: null,
  vigencia: null,
  fechaDesde: '',
  fechaHasta: '',
  ejecutor: null
})

// ========== ESTADO - DATOS ==========
const rows = ref([])
const searched = ref(false)
const selectedRow = ref(null)
const hasSearched = ref(false)
const totalResultados = computed(() => rows.value.length)

// ========== ESTADO - ESTADÍSTICAS ==========
const loadingEstadisticas = ref(true)
const estadisticas = ref([])

// ========== ESTADO - PAGINACIÓN ==========
const currentPage = ref(1)
const itemsPerPage = ref(25)

const totalPages = computed(() => Math.ceil(totalResultados.value / itemsPerPage.value))

const paginatedRows = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage.value
  return rows.value.slice(start, start + itemsPerPage.value)
})

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

// ========== ESTADO - TOTALES ==========
const totalImportes = computed(() => rows.value.reduce((sum, r) => sum + Number(r.importe_global || 0), 0))
const totalPagado = computed(() => rows.value.reduce((sum, r) => sum + Number(r.importe_pago || 0), 0))
const totalSaldo = computed(() => rows.value.reduce((sum, r) => sum + Number(r.saldo || 0), 0))

// ========== ESTADO - MODALES ==========
const showDetail = ref(false)
const selected = ref(null)
const showHistorial = ref(false)
const historial = ref([])
const historialLoading = ref(false)

// ========== FUNCIONES - ESTADÍSTICAS ==========
const cargarEstadisticas = async () => {
  loadingEstadisticas.value = true
  try {
    const response = await execute(OP_STATS, BASE_DB, [])
    estadisticas.value = response?.data || response?.result || []
  } catch (error) {
    estadisticas.value = []
  } finally {
    loadingEstadisticas.value = false
  }
}

// ========== FUNCIONES - BÚSQUEDA ==========
const buscar = async () => {
  showLoading('Buscando expedientes...', 'Consultando ta_15_apremios')
  searched.value = true
  hasSearched.value = true
  selectedRow.value = null
  currentPage.value = 1
  const startTime = performance.now()

  try {
    const params = [
      { name: 'p_zona', type: 'I', value: filters.value.zona },
      { name: 'p_modulo', type: 'I', value: filters.value.modulo },
      { name: 'p_vigencia', type: 'C', value: filters.value.vigencia },
      { name: 'p_fecha_desde', type: 'D', value: filters.value.fechaDesde || null },
      { name: 'p_fecha_hasta', type: 'D', value: filters.value.fechaHasta || null },
      { name: 'p_ejecutor', type: 'I', value: filters.value.ejecutor }
    ]

    const response = await execute(OP_LIST, BASE_DB, params)
    rows.value = response?.data || response?.result || []

    const duration = performance.now() - startTime
    const durationText = duration < 1000 ? `${Math.round(duration)}ms` : `${(duration / 1000).toFixed(2)}s`

    toast.value.duration = durationText
    showToast('success', `Se encontraron ${rows.value.length} expediente(s)`)
  } catch (error) {
    rows.value = []
    handleApiError(error)
  } finally {
    hideLoading()
  }
}

const limpiarFiltros = () => {
  filters.value = {
    zona: null,
    modulo: null,
    vigencia: null,
    fechaDesde: '',
    fechaHasta: '',
    ejecutor: null
  }
  rows.value = []
  hasSearched.value = false
  currentPage.value = 1
  selectedRow.value = null
}

const filtrarPorCategoria = (categoria) => {
  if (categoria === 'TOTAL') {
    limpiarFiltros()
  } else {
    // Por ahora solo filtramos por vigencia para las categorías principales
    const vigenciaMap = {
      'REQUERIMIENTO': '1',
      'EMBARGO': '1',
      'REMATE': '1',
      'ADJUDICACION': '1',
      'CONCLUIDO': '2'
    }
    filters.value.vigencia = vigenciaMap[categoria] || null
  }
  buscar()
}

// ========== FUNCIONES - PAGINACIÓN ==========
const goToPage = (page) => {
  if (page >= 1 && page <= totalPages.value) {
    currentPage.value = page
    selectedRow.value = null
  }
}

const changePageSize = (size) => {
  itemsPerPage.value = parseInt(size)
  currentPage.value = 1
  selectedRow.value = null
}

const toggleFilters = () => {
  showFilters.value = !showFilters.value
}

// ========== FUNCIONES - MODALES ==========
const verDetalle = (row) => {
  selected.value = row
  showDetail.value = true
}

const verHistorial = async (row) => {
  selected.value = row
  showHistorial.value = true
  historialLoading.value = true
  historial.value = []

  try {
    // Llamar al SP completo que retorna todos los registros de historial
    const response = await execute(OP_HISTORIAL, BASE_DB, [
      { name: 'p_control', type: 'I', value: row.folio }
    ])

    let data = response?.data || response?.result || []
    // Asegurar que es un array (el SP puede retornar un solo registro)
    historial.value = Array.isArray(data) ? data : (data ? [data] : [])

    if (historial.value.length > 0) {
      const endTime = performance.now()
      const duration = ((endTime - performance.now()) / 1000).toFixed(2)
      const durationText = duration < 1 ? `${(performance.now()).toFixed(0)}ms` : `${duration}s`
      toast.value.duration = durationText
      showToast('success', `${historial.value.length} movimiento(s) encontrado(s)`)
    }
  } catch (error) {
    historial.value = []
    console.error('Error al cargar historial:', error)
  } finally {
    historialLoading.value = false
  }
}

const exportarHistorial = () => {
  if (historial.value.length === 0) return

  // Crear CSV simple
  const headers = ['Fecha', 'Movimiento', 'Diligencia', 'Vigencia', 'Importe', 'Usuario', 'Observaciones']
  const rows = historial.value.map(h => [
    formatDate(h.fecha_actualiz),
    h.clave_mov || '',
    getDiligenciaDescripcion(h.diligencia),
    getVigenciaTexto(h.vigencia),
    h.importe_global || 0,
    h.usu_descrip || h.usuario || '',
    h.observaciones || ''
  ])

  const csv = [headers.join(','), ...rows.map(r => r.map(c => `"${c}"`).join(','))].join('\n')
  const blob = new Blob(['\ufeff' + csv], { type: 'text/csv;charset=utf-8;' })
  const url = URL.createObjectURL(blob)
  const a = document.createElement('a')
  a.href = url
  a.download = `historial_expediente_${selected.value?.expediente || 'export'}.csv`
  a.click()
  URL.revokeObjectURL(url)
  showToast('success', 'Historial exportado correctamente')
}

const irAModificar = () => {
  if (selected.value) {
    router.push({
      name: 'estacionamiento-exclusivo-modificar-bien',
      query: { folio: selected.value.folio, modulo: selected.value.modulo }
    })
  }
}

// ========== HELPERS ==========
const formatNumber = (num) => new Intl.NumberFormat('es-MX').format(num || 0)

const formatMoney = (value) => {
  return new Intl.NumberFormat('es-MX', { style: 'currency', currency: 'MXN' }).format(value || 0)
}

const formatDate = (dateStr) => {
  if (!dateStr) return '-'
  const date = new Date(dateStr)
  return new Intl.DateTimeFormat('es-MX').format(date)
}

const getModuloNombre = (modulo) => MODULOS[modulo] || `Módulo ${modulo}`

const getStatIcon = (categoria) => {
  const icons = {
    'TOTAL': 'folder-open',
    'REQUERIMIENTO': 'file-alt',
    'EMBARGO': 'gavel',
    'REMATE': 'tag',
    'ADJUDICACION': 'home',
    'CONCLUIDO': 'check-circle'
  }
  return icons[categoria] || 'info-circle'
}

const getVigenciaBadgeClass = (vigencia) => {
  const classes = {
    'Vigente': 'badge-warning',
    'Pagado': 'badge-success',
    'Pago Parcial': 'badge-info',
    'Cancelado': 'badge-secondary',
    '1': 'badge-warning',
    '2': 'badge-success',
    'P': 'badge-info',
    '3': 'badge-secondary'
  }
  return classes[vigencia] || 'badge-secondary'
}

const getSaldoClass = (saldo) => {
  if (saldo > 0) return 'text-danger'
  if (saldo === 0) return 'text-success'
  return ''
}

const getClavePracticado = (clave) => {
  const claves = {
    'P': 'Practicado',
    'N': 'No Practicado',
    'C': 'Citatorio',
    null: 'Pendiente'
  }
  return claves[clave] || clave || 'Pendiente'
}

const getClavePracticadoBadge = (clave) => {
  const clases = {
    'P': 'badge-success',
    'N': 'badge-danger',
    'C': 'badge-warning',
    null: 'badge-secondary'
  }
  return clases[clave] || 'badge-secondary'
}

const getVigenciaIcon = (vigencia) => {
  const iconos = {
    'Vigente': 'clock',
    'Pagado': 'check-circle',
    'Pago Parcial': 'adjust',
    'Cancelado': 'times-circle',
    '1': 'clock',
    '2': 'check-circle',
    'P': 'adjust',
    '3': 'times-circle'
  }
  return iconos[vigencia] || 'question-circle'
}

const getVigenciaClass = (vigencia) => {
  const clases = {
    'Vigente': 'estado-warning',
    'Pagado': 'estado-success',
    'Pago Parcial': 'estado-info',
    'Cancelado': 'estado-secondary',
    '1': 'estado-warning',
    '2': 'estado-success',
    'P': 'estado-info',
    '3': 'estado-secondary'
  }
  return clases[vigencia] || 'estado-secondary'
}

const getVigenciaDescripcion = (vigencia) => {
  const descripciones = {
    'Vigente': 'El expediente está activo y pendiente de cobro',
    'Pagado': 'El adeudo ha sido liquidado completamente',
    'Pago Parcial': 'Se han recibido pagos parciales, saldo pendiente',
    'Cancelado': 'El expediente ha sido dado de baja',
    '1': 'El expediente está activo y pendiente de cobro',
    '2': 'El adeudo ha sido liquidado completamente',
    'P': 'Se han recibido pagos parciales, saldo pendiente',
    '3': 'El expediente ha sido dado de baja'
  }
  return descripciones[vigencia] || 'Estado no definido'
}

const getPorcentajePago = (expediente) => {
  if (!expediente || !expediente.importe_global || expediente.importe_global <= 0) return 0
  const porcentaje = ((expediente.importe_pago || 0) / expediente.importe_global) * 100
  return Math.min(100, Math.round(porcentaje * 10) / 10)
}

// ========== HELPERS HISTORIAL ==========
const getMovimientoIcon = (clave) => {
  const iconos = {
    'AL': 'plus-circle',       // Alta
    'MO': 'edit',              // Modificación
    'PA': 'dollar-sign',       // Pago
    'CA': 'times-circle',      // Cancelación
    'RE': 'file-alt',          // Requerimiento
    'EM': 'gavel',             // Embargo
    'RM': 'tag',               // Remate
    'AD': 'home',              // Adjudicación
    'AS': 'user-check',        // Asignación ejecutor
    'PR': 'check-double',      // Practicado
    'NO': 'bell',              // Notificación
    'CI': 'clock'              // Citatorio
  }
  return iconos[clave] || 'file'
}

const getMovimientoBadgeClass = (clave) => {
  const clases = {
    'AL': 'badge-success',
    'MO': 'badge-info',
    'PA': 'badge-success',
    'CA': 'badge-danger',
    'RE': 'badge-warning',
    'EM': 'badge-danger',
    'RM': 'badge-purple',
    'AD': 'badge-primary',
    'AS': 'badge-info',
    'PR': 'badge-success',
    'NO': 'badge-warning',
    'CI': 'badge-secondary'
  }
  return clases[clave] || 'badge-secondary'
}

const getMovimientoDescripcion = (clave) => {
  const descripciones = {
    'AL': 'Alta de expediente',
    'MO': 'Modificación de datos',
    'PA': 'Registro de pago',
    'CA': 'Cancelación',
    'RE': 'Requerimiento',
    'EM': 'Embargo',
    'RM': 'Remate',
    'AD': 'Adjudicación',
    'AS': 'Asignación de ejecutor',
    'PR': 'Diligencia practicada',
    'NO': 'Notificación',
    'CI': 'Citatorio'
  }
  return descripciones[clave] || 'Movimiento'
}

const getTimelineClass = (clave) => {
  const clases = {
    'PA': 'timeline-success',
    'CA': 'timeline-danger',
    'EM': 'timeline-danger',
    'AL': 'timeline-success',
    'RE': 'timeline-warning',
    'NO': 'timeline-warning'
  }
  return clases[clave] || 'timeline-default'
}

const getDiligenciaBadge = (diligencia) => {
  const badges = {
    'R': 'badge-warning',     // Requerimiento
    'E': 'badge-danger',      // Embargo
    'M': 'badge-purple',      // Remate
    'A': 'badge-info',        // Adjudicación
    'N': 'badge-secondary',   // Notificación
    'C': 'badge-secondary'    // Citatorio
  }
  return badges[diligencia] || 'badge-secondary'
}

const getDiligenciaDescripcion = (diligencia) => {
  const descripciones = {
    'R': 'Requerimiento',
    'E': 'Embargo',
    'M': 'Remate',
    'A': 'Adjudicación',
    'N': 'Notificación',
    'C': 'Citatorio',
    '1': 'Requerimiento',
    '2': 'Embargo',
    '3': 'Remate',
    '4': 'Adjudicación'
  }
  return descripciones[diligencia] || diligencia || '-'
}

const getVigenciaTexto = (vigencia) => {
  const textos = {
    '1': 'Vigente',
    '2': 'Pagado',
    '3': 'Cancelado',
    'P': 'Pago Parcial',
    'V': 'Vigente'
  }
  return textos[vigencia] || vigencia || '-'
}

// ========== LIFECYCLE ==========
onMounted(() => {
  cargarEstadisticas()
  buscar()
})

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
</script>

<!-- Sin estilos scoped - Todo desde municipal-theme.css -->
