<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="file-alt" />
      </div>
      <div class="module-view-info">
        <h1>Consulta Individual de Folios</h1>
        <p>Cementerios - Información completa del folio RCM</p>
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
      </div>
    </div>

    <div class="module-view-content">
      <!-- Búsqueda de Folio -->
      <div class="municipal-card mb-3">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="search" />
            Buscar Folio
          </h5>
        </div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label required">Número de Folio (Control RCM)</label>
              <input
                v-model.number="folioABuscar"
                type="number"
                class="municipal-form-control"
                placeholder="Ingrese número de folio"
                @keyup.enter="buscarFolio"
                min="1"
              />
            </div>
            <div class="form-group">
              <button @click="buscarFolio" class="btn-municipal-primary">
                <font-awesome-icon icon="search" />
                Buscar
              </button>
              <button @click="limpiar" class="btn-municipal-secondary">
                <font-awesome-icon icon="eraser" />
                Limpiar
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- Datos del Folio -->
      <div v-if="folio" class="municipal-card mb-3">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="info-circle" />
            Información del Folio {{ folio.control_rcm }}
          </h5>
          <button @click="imprimirFolio" class="btn-municipal-secondary">
            <font-awesome-icon icon="print" />
            Imprimir
          </button>
        </div>
        <div class="municipal-card-body">
          <div class="info-grid-completo">
            <!-- Datos del Titular -->
            <div class="info-section">
              <h6 class="section-title">
                <font-awesome-icon icon="user" />
                Datos del Titular
              </h6>
              <div class="info-item">
                <span class="info-label">Nombre:</span>
                <span class="info-value">{{ folio.nombre }}</span>
              </div>
              <div class="info-item">
                <span class="info-label">Domicilio:</span>
                <span class="info-value">{{ folio.domicilio }}</span>
              </div>
              <div class="info-item">
                <span class="info-label">Exterior:</span>
                <span class="info-value">{{ folio.exterior || 'N/A' }}</span>
              </div>
              <div class="info-item">
                <span class="info-label">Interior:</span>
                <span class="info-value">{{ folio.interior || 'N/A' }}</span>
              </div>
              <div class="info-item">
                <span class="info-label">Colonia:</span>
                <span class="info-value">{{ folio.colonia }}</span>
              </div>
            </div>

            <!-- Ubicación -->
            <div class="info-section">
              <h6 class="section-title">
                <font-awesome-icon icon="map-marker-alt" />
                Ubicación
              </h6>
              <div class="info-item">
                <span class="info-label">Cementerio:</span>
                <span class="info-value">{{ cementerioNombre }}</span>
              </div>
              <div class="info-item">
                <span class="info-label">Clase:</span>
                <span class="info-value">{{ folio.clase }}{{ folio.clase_alfa || '' }}</span>
              </div>
              <div class="info-item">
                <span class="info-label">Sección:</span>
                <span class="info-value">{{ folio.seccion }}{{ folio.seccion_alfa || '' }}</span>
              </div>
              <div class="info-item">
                <span class="info-label">Línea:</span>
                <span class="info-value">{{ folio.linea }}{{ folio.linea_alfa || '' }}</span>
              </div>
              <div class="info-item">
                <span class="info-label">Fosa:</span>
                <span class="info-value">{{ folio.fosa }}{{ folio.fosa_alfa || '' }}</span>
              </div>
              <div class="info-item">
                <span class="info-label">Metros:</span>
                <span class="info-value">{{ folio.metros }} m²</span>
              </div>
              <div class="info-item">
                <span class="info-label">Tipo:</span>
                <span class="info-value badge-tipo">{{ tipoSepulcro }}</span>
              </div>
            </div>

            <!-- Estado de Pago -->
            <div class="info-section">
              <h6 class="section-title">
                <font-awesome-icon icon="calendar-check" />
                Estado de Pago
              </h6>
              <div class="info-item">
                <span class="info-label">Año Pagado:</span>
                <span class="info-value highlight-year">{{ folio.axo_pagado }}</span>
              </div>
              <div class="info-item">
                <span class="info-label">Bonificación Disponible:</span>
                <span class="info-value bonificacion">${{ formatearMoneda(bonificacionTotal) }}</span>
              </div>
            </div>

            <!-- Datos Adicionales (RFC, CURP, etc) -->
            <div v-if="datosAdicionales" class="info-section">
              <h6 class="section-title">
                <font-awesome-icon icon="id-card" />
                Datos Adicionales
              </h6>
              <div class="info-item">
                <span class="info-label">RFC:</span>
                <span class="info-value">{{ datosAdicionales.rfc || 'N/A' }}</span>
              </div>
              <div class="info-item">
                <span class="info-label">CURP:</span>
                <span class="info-value">{{ datosAdicionales.curp || 'N/A' }}</span>
              </div>
              <div class="info-item">
                <span class="info-label">Teléfono:</span>
                <span class="info-value">{{ datosAdicionales.telefono || 'N/A' }}</span>
              </div>
              <div class="info-item">
                <span class="info-label">Clave IFE:</span>
                <span class="info-value">{{ datosAdicionales.clave_ife || 'N/A' }}</span>
              </div>
            </div>

            <!-- Observaciones -->
            <div v-if="folio.observaciones" class="info-section full-width">
              <h6 class="section-title">
                <font-awesome-icon icon="comment" />
                Observaciones
              </h6>
              <p class="observaciones-text">{{ folio.observaciones }}</p>
            </div>

            <!-- Última Actualización -->
            <div class="info-section">
              <h6 class="section-title">
                <font-awesome-icon icon="clock" />
                Última Actualización
              </h6>
              <div class="info-item">
                <span class="info-label">Usuario:</span>
                <span class="info-value">{{ usuarioNombre || folio.usuario }}</span>
              </div>
              <div class="info-item">
                <span class="info-label">Fecha:</span>
                <span class="info-value">{{ formatearFecha(folio.fecha_mov) }}</span>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Tabs con información detallada -->
      <div v-if="folio" class="municipal-card">
        <div class="municipal-card-body">
          <div class="municipal-tabs">
            <!-- Tab Headers -->
            <div class="tabs-header">
              <button
                v-for="tab in tabs"
                :key="tab.id"
                :class="['municipal-tab', { 'active': tabActivo === tab.id }]"
                @click="tabActivo = tab.id"
              >
                <font-awesome-icon :icon="tab.icon" />
                {{ tab.label }}
                <span v-if="tab.count > 0" class="badge-count">{{ tab.count }}</span>
              </button>
            </div>

            <!-- Tab Content -->
            <div class="tabs-content">
              <!-- Tab 1: Adeudos -->
              <div v-show="tabActivo === 'adeudos'" class="tab-pane">
                <h6 class="tab-title">Adeudos Vigentes ({{ adeudos.length }})</h6>
                <div v-if="adeudos.length > 0" class="table-responsive">
                  <table class="municipal-table">
                    <thead class="municipal-table-header">
                      <tr>
                        <th>Año</th>
                        <th>Importe</th>
                        <th>Recargos</th>
                        <th>Descto Importe</th>
                        <th>Descto Recargos</th>
                        <th>Actualización</th>
                        <th>Total</th>
                      </tr>
                    </thead>
                    <tbody>
                      <tr
                        v-for="adeudo in adeudos"
                        :key="adeudo.id_adeudo"
                        @click="selectedRow = adeudo"
                        :class="{ 'table-row-selected': selectedRow === adeudo }"
                        class="row-hover"
                      >
                        <td>{{ adeudo.axo_adeudo }}</td>
                        <td>${{ formatearMoneda(adeudo.importe) }}</td>
                        <td>${{ formatearMoneda(adeudo.importe_recargos) }}</td>
                        <td class="descuento">${{ formatearMoneda(adeudo.descto_impote) }}</td>
                        <td class="descuento">${{ formatearMoneda(adeudo.descto_recargos) }}</td>
                        <td>${{ formatearMoneda(adeudo.actualizacion) }}</td>
                        <td class="total-amount">${{ formatearMoneda(calcularTotalAdeudo(adeudo)) }}</td>
                      </tr>
                    </tbody>
                    <tfoot>
                      <tr class="totals-row">
                        <td><strong>TOTAL ADEUDOS:</strong></td>
                        <td colspan="5"></td>
                        <td class="total-amount"><strong>${{ formatearMoneda(calcularTotalAdeudos()) }}</strong></td>
                      </tr>
                    </tfoot>
                  </table>
                </div>
                <div v-else class="alert-info">
                  <font-awesome-icon icon="info-circle" />
                  No hay adeudos vigentes
                </div>
              </div>

              <!-- Tab 2: Pagos -->
              <div v-show="tabActivo === 'pagos'" class="tab-pane">
                <h6 class="tab-title">Historial de Pagos ({{ pagos.length }})</h6>
                <div v-if="pagos.length > 0" class="table-responsive">
                  <table class="municipal-table">
                    <thead class="municipal-table-header">
                      <tr>
                        <th>Tipo</th>
                        <th>Fecha</th>
                        <th>Recibo-Caja-Op</th>
                        <th>Años</th>
                        <th>Importe</th>
                        <th>Recargos</th>
                        <th>Total</th>
                        <th>Usuario</th>
                      </tr>
                    </thead>
                    <tbody>
                      <tr
                        v-for="(pago, idx) in pagos"
                        :key="`pago-${idx}`"
                        @click="selectedRow = pago"
                        :class="{ 'table-row-selected': selectedRow === pago }"
                        class="row-hover"
                      >
                        <td><span :class="['badge-tipo', pago.tipopag.toLowerCase()]">{{ pago.tipopag }}</span></td>
                        <td>{{ formatearFecha(pago.fecha_mov) }}</td>
                        <td>{{ pago.recing }}-{{ pago.cajing }}-{{ pago.opcaja }}</td>
                        <td>{{ pago.axo_pago_desde }}-{{ pago.axo_pago_hasta }}</td>
                        <td>${{ formatearMoneda(pago.importe_anual) }}</td>
                        <td>${{ formatearMoneda(pago.importe_recargos) }}</td>
                        <td class="total-amount">${{ formatearMoneda(pago.importe_anual + pago.importe_recargos) }}</td>
                        <td>{{ pago.usuario }}</td>
                      </tr>
                    </tbody>
                  </table>
                </div>
                <div v-else class="alert-info">
                  <font-awesome-icon icon="info-circle" />
                  No hay pagos registrados
                </div>
              </div>

              <!-- Tab 3: Descuentos/Recargos -->
              <div v-show="tabActivo === 'descuentos'" class="tab-pane">
                <h6 class="tab-title">Descuentos y Recargos Aplicados ({{ descuentosRecargos.length }})</h6>
                <div v-if="descuentosRecargos.length > 0" class="table-responsive">
                  <table class="municipal-table">
                    <thead class="municipal-table-header">
                      <tr>
                        <th>Año Inicio</th>
                        <th>Año Fin</th>
                        <th>Porcentaje</th>
                        <th>Fecha Alta</th>
                        <th>Usuario Alta</th>
                        <th>Fecha Pago</th>
                        <th>Recibo</th>
                        <th>Estado</th>
                      </tr>
                    </thead>
                    <tbody>
                      <tr
                        v-for="desc in descuentosRecargos"
                        :key="desc.id_descto"
                        @click="selectedRow = desc"
                        :class="{ 'table-row-selected': selectedRow === desc }"
                        class="row-hover"
                      >
                        <td>{{ desc.axoinicio }}</td>
                        <td>{{ desc.axofin }}</td>
                        <td>{{ desc.porcentaje }}%</td>
                        <td>{{ formatearFechaHora(desc.fecha_alta) }}</td>
                        <td>{{ desc.nombre_usuario }}</td>
                        <td>{{ formatearFechaHora(desc.fec_pag) }}</td>
                        <td>{{ desc.id_rec }}-{{ desc.caja }}-{{ desc.operac }}</td>
                        <td><span :class="['badge-estado', desc.vigencia]">{{ desc.vigencia === 'A' ? 'Activo' : 'Inactivo' }}</span></td>
                      </tr>
                    </tbody>
                  </table>
                </div>
                <div v-else class="alert-info">
                  <font-awesome-icon icon="info-circle" />
                  No hay descuentos/recargos aplicados
                </div>
              </div>

              <!-- Tab 4: Descuentos Pendientes -->
              <div v-show="tabActivo === 'pendientes'" class="tab-pane">
                <h6 class="tab-title">Descuentos Pendientes ({{ descuentosPendientes.length }})</h6>
                <div v-if="descuentosPendientes.length > 0" class="table-responsive">
                  <table class="municipal-table">
                    <thead class="municipal-table-header">
                      <tr>
                        <th>Año</th>
                        <th>Descuento</th>
                        <th>Fecha Alta</th>
                        <th>Usuario</th>
                        <th>Reactivar</th>
                        <th>Estado</th>
                      </tr>
                    </thead>
                    <tbody>
                      <tr
                        v-for="pen in descuentosPendientes"
                        :key="pen.control_des"
                        @click="selectedRow = pen"
                        :class="{ 'table-row-selected': selectedRow === pen }"
                        class="row-hover"
                      >
                        <td>{{ pen.axo_descto }}</td>
                        <td class="descuento">{{ pen.descuento }}%</td>
                        <td>{{ formatearFecha(pen.fecha_alta) }}</td>
                        <td>{{ pen.nombre_usuario }}</td>
                        <td>{{ pen.reactivar === 'S' ? 'Sí' : 'No' }}</td>
                        <td><span :class="['badge-estado', pen.vigencia]">{{ pen.vigencia === 'A' ? 'Activo' : 'Inactivo' }}</span></td>
                      </tr>
                    </tbody>
                  </table>
                </div>
                <div v-else class="alert-info">
                  <font-awesome-icon icon="info-circle" />
                  No hay descuentos pendientes
                </div>
              </div>

              <!-- Tab 5: Historial de Cambios -->
              <div v-show="tabActivo === 'historial'" class="tab-pane">
                <h6 class="tab-title">Historial de Cambios ({{ historial.length }})</h6>
                <div v-if="historial.length > 0" class="table-responsive">
                  <table class="municipal-table">
                    <thead class="municipal-table-header">
                      <tr>
                        <th>Fecha Histórico</th>
                        <th>Nombre Anterior</th>
                        <th>Ubicación</th>
                        <th>Año Pagado</th>
                        <th>Usuario</th>
                        <th>Fecha Movimiento</th>
                      </tr>
                    </thead>
                    <tbody>
                      <tr
                        v-for="hist in historial"
                        :key="hist.id_historico"
                        @click="selectedRow = hist"
                        :class="{ 'table-row-selected': selectedRow === hist }"
                        class="row-hover"
                      >
                        <td>{{ formatearFecha(hist.fecha_his) }}</td>
                        <td>{{ hist.nombre }}</td>
                        <td>{{ formatearUbicacionHistorico(hist) }}</td>
                        <td>{{ hist.axo_pagado }}</td>
                        <td>{{ hist.nombre_usuario || hist.usuario }}</td>
                        <td>{{ formatearFecha(hist.fecha_mov) }}</td>
                      </tr>
                    </tbody>
                  </table>
                </div>
                <div v-else class="alert-info">
                  <font-awesome-icon icon="info-circle" />
                  No hay historial de cambios
                </div>
              </div>

              <!-- Tab 6: Contactos Extra -->
              <div v-show="tabActivo === 'extras'" class="tab-pane">
                <h6 class="tab-title">Contactos Extra ({{ contactosExtra.length }})</h6>
                <div v-if="contactosExtra.length > 0" class="table-responsive">
                  <table class="municipal-table">
                    <thead class="municipal-table-header">
                      <tr>
                        <th>Nombre</th>
                        <th>Parentesco</th>
                        <th>Domicilio</th>
                        <th>Teléfono</th>
                        <th>Correo</th>
                        <th>Fecha Alta</th>
                      </tr>
                    </thead>
                    <tbody>
                      <tr
                        v-for="extra in contactosExtra"
                        :key="extra.id_control"
                        @click="selectedRow = extra"
                        :class="{ 'table-row-selected': selectedRow === extra }"
                        class="row-hover"
                      >
                        <td>{{ extra.nombre }}</td>
                        <td>{{ extra.parentesco }}</td>
                        <td>{{ extra.domicilio }}</td>
                        <td>{{ extra.telefono }}</td>
                        <td>{{ extra.correo }}</td>
                        <td>{{ formatearFecha(extra.fecalta) }}</td>
                      </tr>
                    </tbody>
                  </table>
                </div>
                <div v-else class="alert-info">
                  <font-awesome-icon icon="info-circle" />
                  No hay contactos extra registrados
                </div>
              </div>

              <!-- Tab 7: Resumen Cajero -->
              <div v-show="tabActivo === 'cajero'" class="tab-pane">
                <h6 class="tab-title">Resumen para Cajero {{ anioActual }}</h6>
                <div v-if="resumenCajero.length > 0" class="table-responsive">
                  <table class="municipal-table">
                    <thead class="municipal-table-header">
                      <tr>
                        <th>Concepto</th>
                        <th>Clave</th>
                        <th>Monto</th>
                        <th>Cuenta</th>
                        <th>Observaciones</th>
                      </tr>
                    </thead>
                    <tbody>
                      <tr
                        v-for="(item, idx) in resumenCajero"
                        :key="`cajero-${idx}`"
                        @click="selectedRow = item"
                        :class="{ 'table-row-selected': selectedRow === item }"
                        class="row-hover"
                      >
                        <td>{{ item.slinea }}</td>
                        <td>{{ item.clave }}</td>
                        <td :class="item.total < 0 ? 'total-negativo' : 'total-positivo'">${{ formatearMoneda(Math.abs(item.total)) }}</td>
                        <td>{{ item.ctaapli }}</td>
                        <td>{{ item.observ }}</td>
                      </tr>
                    </tbody>
                  </table>
                </div>
                <div v-else class="alert-info">
                  <font-awesome-icon icon="info-circle" />
                  No hay movimientos del año {{ anioActual }}
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Empty State - Sin resultados -->
      <div v-else-if="busquedaRealizada && !folio" class="empty-state">
        <div class="empty-state-icon">
          <font-awesome-icon icon="inbox" size="3x" />
        </div>
        <h4>Sin resultados</h4>
        <p>No se encontró el folio especificado</p>
      </div>

      <!-- Empty State - Sin búsqueda -->
      <div v-else-if="!busquedaRealizada && !folio" class="empty-state">
        <div class="empty-state-icon">
          <font-awesome-icon icon="file-alt" size="3x" />
        </div>
        <h4>Consulta Individual de Folios</h4>
        <p>Ingrese un número de folio para consultar la información completa</p>
      </div>

      <!-- Toast Notifications -->
      <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
        <div class="toast-content">
          <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
          <span class="toast-message">{{ toast.message }}</span>
        </div>
        <button class="toast-close" @click="hideToast">
          <font-awesome-icon icon="times" />
        </button>
      </div>

      <!-- Modal de Ayuda y Documentación -->
      <DocumentationModal
        :show="showDocModal"
        :componentName="'ConIndividual'"
        :moduleName="'cementerios'"
        :docType="docType"
        :title="'Consulta Individual de Folios'"
        @close="showDocModal = false"
      />
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { useApi } from '@/composables/useApi'
import { useGlobalLoading } from '@/composables/useGlobalLoading'

const { execute } = useApi()
const { showLoading, hideLoading } = useGlobalLoading()

// Sistema de toast manual
const toast = ref({
  show: false,
  type: 'info',
  message: ''
})

let toastTimeout = null

const showToast = (type, message) => {
  if (toastTimeout) {
    clearTimeout(toastTimeout)
  }

  toast.value = {
    show: true,
    type,
    message
  }

  toastTimeout = setTimeout(() => {
    hideToast()
  }, 3000)
}

const hideToast = () => {
  toast.value.show = false
}

const getToastIcon = (type) => {
  const icons = {
    success: 'check-circle',
    error: 'exclamation-circle',
    warning: 'exclamation-triangle',
    info: 'info-circle'
  }
  return icons[type] || 'info-circle'
}

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
const folioABuscar = ref(null)
const folio = ref(null)
const cementerioNombre = ref('')
const datosAdicionales = ref(null)
const bonificacionTotal = ref(0)
const usuarioNombre = ref('')
const pagos = ref([])
const adeudos = ref([])
const descuentosRecargos = ref([])
const descuentosPendientes = ref([])
const historial = ref([])
const contactosExtra = ref([])
const resumenCajero = ref([])
const busquedaRealizada = ref(false)
const tabActivo = ref('adeudos')
const anioActual = new Date().getFullYear()
const selectedRow = ref(null)
const hasSearched = ref(false)

// Tabs configuration (Pascal sPageControl1)
const tabs = computed(() => [
  { id: 'adeudos', label: 'Adeudos', icon: 'exclamation-circle', count: adeudos.value.length },
  { id: 'pagos', label: 'Pagos', icon: 'money-bill-wave', count: pagos.value.length },
  { id: 'descuentos', label: 'Desc/Rec', icon: 'percent', count: descuentosRecargos.value.length },
  { id: 'pendientes', label: 'Pendientes', icon: 'clock', count: descuentosPendientes.value.length },
  { id: 'historial', label: 'Historial', icon: 'history', count: historial.value.length },
  { id: 'extras', label: 'Contactos', icon: 'address-book', count: contactosExtra.value.length },
  { id: 'cajero', label: 'Cajero', icon: 'cash-register', count: resumenCajero.value.length }
])

// Tipo de sepulcro (Pascal línea 435-451)
const tipoSepulcro = computed(() => {
  if (!folio.value) return ''
  const tipo = folio.value.tipo
  if (tipo === 'F') return 'FOSA'
  if (tipo === 'U') return 'URNA'
  if (tipo === 'G') return 'GAVETA'
  return tipo || 'N/A'
})

// Buscar folio (Pascal inicio línea 412)
const buscarFolio = async () => {
  if (!folioABuscar.value || folioABuscar.value <= 0) {
    showToast('warning', 'Ingrese un número de folio válido')
    return
  }

  showLoading('Buscando folio...', 'Por favor espere')
  hasSearched.value = true
  selectedRow.value = null
  try {
    /* Pascal línea 412-466:
    procedure TFrmConIndividual.inicio(vfolio:integer);
    begin
    vfolioz:=vfolio;
    DecodeDate(date, Year, M, Day);
    limpiacampos;
    ...12 queries abiertas...
    end;
    */

    // 1. QryestoyIn (Pascal línea 432-433)
    const responseFolio = await execute(
      'sp_conindividual_buscar_folio',
      'cementerio',
      [
        { nombre: 'p_control_rcm', valor: folioABuscar.value, tipo: 'integer' }
      ],
      'function',
      null,
      'publico'
    )

    busquedaRealizada.value = true

    if (!responseFolio || responseFolio.length === 0) {
      limpiar()
      showToast('warning', 'No se encontró el folio')
      return
    }

    if(responseFolio?.result?.length>0){
      folio.value = responseFolio.result[0]
    }
    

    // 2. QryCem (Pascal línea 463)
    const responseCem = await execute(
      'sp_conindividual_obtener_nombre_cementerio',
      'cementerio',
      [
        { nombre: 'p_cementerio', valor: folio.value.cementerio, tipo: 'string' }
      ],
      'function',
      null,
      'publico'
    )
    
    cementerioNombre.value = responseCem?.result?.[0]?.nombre || folio.value.cementerio

    // 3. Query1 - Usuario (Pascal línea 434)
    const responseUsuario = await execute(
      'sp_conindividual_obtener_usuario',
      'cementerio',
      [
        { nombre: 'p_id_usuario', valor: folio.value.usuario, tipo: 'integer' }
      ],
      'function',
      null,
      'publico'
    )
    usuarioNombre.value = responseUsuario?.result?.[0]?.nombre || ''

    // 4. QryPagos (Pascal línea 455-456)
    const responsePagos = await execute(
      'sp_conindividual_listar_pagos',
      'cementerio',
      [
        { nombre: 'p_control_rcm', valor: folioABuscar.value, tipo: 'integer' }
      ],
      'function',
      null,
      'publico'
    )
    pagos.value = responsePagos?.result || []

    // 5. QryAdic (Pascal línea 457)
    const responseAdic = await execute(
      'sp_conindividual_obtener_adicional',
      'cementerio',
      [
        { nombre: 'p_control_rcm', valor: folioABuscar.value, tipo: 'integer' }
      ],
      'function',
      null,
      'publico'
    )
    datosAdicionales.value = responseAdic?.result?.[0] || null

    // 6. QryPen - Descuentos pendientes (Pascal línea 458)
    const responseDescuentosPend = await execute(
      'sp_conindividual_listar_descuentos_pendientes',
      'cementerio',
      [
        { nombre: 'p_control_rcm', valor: folioABuscar.value, tipo: 'integer' }
      ],
      'function',
      null,
      'publico'
    )
    descuentosPendientes.value = responseDescuentosPend?.result || []

    // 7. QryBonif (Pascal línea 459)
    const responseBonif = await execute(
      'sp_conindividual_obtener_bonificacion',
      'cementerio',
      [
        { nombre: 'p_control_rcm', valor: folioABuscar.value, tipo: 'integer' }
      ],
      'function',
      null,
      'publico'
    )
    bonificacionTotal.value = responseBonif?.result?.[0]?.bonifica || 0

    // 8. Qryadeudo (Pascal línea 460)
    const responseAdeudos = await execute(
      'sp_conindividual_listar_adeudos',
      'cementerio',
      [
        { nombre: 'p_control_rcm', valor: folioABuscar.value, tipo: 'integer' }
      ],
      'function',
      null,
      'publico'
    )
    adeudos.value = responseAdeudos?.result || []

    // 9. QryDesrec (Pascal línea 461)
    const responseDescuentosRec = await execute(
      'sp_conindividual_listar_descuentos_recargos',
      'cementerio',
      [
        { nombre: 'p_control_rcm', valor: folioABuscar.value, tipo: 'integer' }
      ],
      'function',
      null,
      'publico'
    )
    descuentosRecargos.value = responseDescuentosRec?.result || []

    // 10. QryHisto (Pascal línea 462)
    const responseHistorial = await execute(
      'sp_conindividual_listar_historial',
      'cementerio',
      [
        { nombre: 'p_control_rcm', valor: folioABuscar.value, tipo: 'integer' }
      ],
      'function',
      null,
      'publico'
    )
    historial.value = responseHistorial?.result || []

    // 11. QryExtra (Pascal línea 464)
    const responseExtras = await execute(
      'sp_conindividual_listas_extras',
      'cementerio',
      [
        { nombre: 'p_control_rcm', valor: folioABuscar.value, tipo: 'integer' }
      ],
      'function',
      null,
      'publico'
    )
    contactosExtra.value = responseExtras?.result || []

    // 12. StrdPrcCajero (Pascal línea 452-454)
    const responseCajero = await execute(
      'sp_conindividual_resumen_cajero',
      'cementerio',
      [
        { nombre: 'p_control_rcm', valor: folioABuscar.value, tipo: 'integer' },
        { nombre: 'p_axo', valor: anioActual, tipo: 'integer' }
      ],
      'function',
      null,
      'publico'
    )
    resumenCajero.value = responseCajero?.result || []

    showToast('success', 'Folio cargado exitosamente')

  } catch (error) {
    console.error('Error al buscar folio:', error)
    showToast('error', 'Error al buscar folio: ' + error.message)
    limpiar()
  } finally {
    hideLoading()
  }
}

// Limpiar (Pascal limpiacampos línea 488)
const limpiar = () => {
  folioABuscar.value = null
  folio.value = null
  cementerioNombre.value = ''
  datosAdicionales.value = null
  bonificacionTotal.value = 0
  usuarioNombre.value = ''
  pagos.value = []
  adeudos.value = []
  descuentosRecargos.value = []
  descuentosPendientes.value = []
  historial.value = []
  contactosExtra.value = []
  resumenCajero.value = []
  busquedaRealizada.value = false
  hasSearched.value = false
  tabActivo.value = 'adeudos'
  selectedRow.value = null
}

// Imprimir (Pascal sBitBtn1Click línea 507-509)
const imprimirFolio = () => {
  // TODO: Implementar generación de PDF/Reporte
  // Pascal: ppReport1.Print;
  showToast('info', 'Función de impresión próximamente')
}

// Cálculos
const calcularTotalAdeudo = (adeudo) => {
  return (adeudo.importe || 0) +
         (adeudo.importe_recargos || 0) +
         (adeudo.actualizacion || 0) -
         (adeudo.descto_impote || 0) -
         (adeudo.descto_recargos || 0)
}

const calcularTotalAdeudos = () => {
  return adeudos.value.reduce((sum, adeudo) => sum + calcularTotalAdeudo(adeudo), 0)
}

// Formateadores
const formatearMoneda = (valor) => {
  if (!valor) return '0.00'
  return parseFloat(valor).toFixed(2)
}

const formatearFecha = (fecha) => {
  if (!fecha) return '-'
  const date = new Date(fecha)
  return date.toLocaleDateString('es-MX')
}

const formatearFechaHora = (fecha) => {
  if (!fecha) return '-'
  const date = new Date(fecha)
  return date.toLocaleString('es-MX')
}

const formatearUbicacionHistorico = (hist) => {
  return `Cl:${hist.clase}${hist.clase_alfa || ''} Sec:${hist.seccion}${hist.seccion_alfa || ''} Lin:${hist.linea}${hist.linea_alfa || ''} Fosa:${hist.fosa}${hist.fosa_alfa || ''}`
}
</script>

