<template>
  <div class="module-view">
    <!-- Header -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="gavel" />
      </div>
      <div class="module-view-info">
        <h1>Aplicación de Multas</h1>
        <p>Aplicación de sanciones por infracciones a contratos</p>
      </div>
      <button
        type="button"
        class="btn-help-icon"
        @click="mostrarAyuda = true"
        title="Ayuda"
      >
        <font-awesome-icon icon="question-circle" />
      </button>
    </div>

    <div class="module-view-content">
      <!-- Tabs -->
      <div class="municipal-tabs">
        <button
          class="municipal-tab"
          :class="{ active: tabActual === 'aplicar' }"
          @click="tabActual = 'aplicar'"
        >
          <font-awesome-icon icon="gavel" />
          Aplicar Multa
        </button>
        <button
          class="municipal-tab"
          :class="{ active: tabActual === 'consulta' }"
          @click="tabActual = 'consulta'"
        >
          <font-awesome-icon icon="list" />
          Consultar Multas
        </button>
      </div>

      <!-- Tab: Aplicar Multa -->
      <div v-if="tabActual === 'aplicar'">
        <!-- Paso 1: Búsqueda de Contrato -->
        <div v-if="paso === 1" class="municipal-card">
          <div class="municipal-card-header">
            <h5>Paso 1: Búsqueda de Contrato</h5>
          </div>
          <div class="municipal-card-body">
            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label">Número de Contrato</label>
                <div class="input-group">
                  <input
                    type="text"
                    class="municipal-form-control"
                    v-model="busqueda.num_contrato"
                    @keyup.enter="buscarContrato"
                    placeholder="Ingrese número de contrato"
                  />
                  <button class="btn-municipal-primary" @click="buscarContrato" :disabled="cargando">
                    <font-awesome-icon icon="search" />
                    Buscar
                  </button>
                </div>
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Cuenta Predial</label>
                <div class="input-group">
                  <input
                    type="text"
                    class="municipal-form-control"
                    v-model="busqueda.cuenta_predial"
                    @keyup.enter="buscarPorPredial"
                    placeholder="Ingrese cuenta predial"
                  />
                  <button class="btn-municipal-primary" @click="buscarPorPredial" :disabled="cargando">
                    <font-awesome-icon icon="search" />
                    Buscar
                  </button>
                </div>
              </div>
            </div>

            <!-- Datos del Contrato Encontrado -->
            <div v-if="contratoSeleccionado" class="alert-success">
              <h6>
                <font-awesome-icon icon="check-circle" />
                Contrato Encontrado
              </h6>
              <div class="info-grid">
                <div class="info-item">
                  <strong>Contrato:</strong> {{ contratoSeleccionado.num_contrato }}<br>
                  <strong>Control:</strong> {{ contratoSeleccionado.control_contrato }}
                </div>
                <div class="info-item">
                  <strong>Contribuyente:</strong> {{ contratoSeleccionado.contribuyente }}<br>
                  <strong>RFC:</strong> {{ contratoSeleccionado.rfc || 'N/A' }}
                </div>
                <div class="info-item">
                  <strong>Domicilio:</strong> {{ contratoSeleccionado.domicilio }}<br>
                  <strong>Tipo:</strong> {{ formatTipoAseo(contratoSeleccionado.tipo_aseo) }}
                </div>
              </div>
              <div class="info-grid mt-2">
                <div class="info-item">
                  <strong>Status:</strong>
                  <span class="badge-success" v-if="contratoSeleccionado.status === 'A'">Activo</span>
                  <span class="badge-danger" v-else>Inactivo</span>
                </div>
                <div class="info-item">
                  <strong>Adeudos:</strong>
                  <span class="text-danger">{{ contratoSeleccionado.adeudos_pendientes || 0 }}</span>
                </div>
                <div class="info-item">
                  <strong>Multas Previas:</strong>
                  <span class="text-warning">{{ contratoSeleccionado.multas_aplicadas || 0 }}</span>
                </div>
              </div>
              <div class="mt-3">
                <button class="btn-municipal-primary" @click="paso = 2">
                  <font-awesome-icon icon="arrow-right" />
                  Continuar
                </button>
              </div>
            </div>
          </div>
        </div>

        <!-- Paso 2: Configuración de la Multa -->
        <div v-if="paso === 2" class="municipal-card">
          <div class="municipal-card-header bg-warning">
            <h5>Paso 2: Configuración de la Multa</h5>
          </div>
          <div class="municipal-card-body">
            <!-- Resumen del Contrato -->
            <div class="alert-info mb-4">
              <strong>Contrato:</strong> {{ contratoSeleccionado.num_contrato }} -
              <strong>Contribuyente:</strong> {{ contratoSeleccionado.contribuyente }}
            </div>

            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label">Tipo de Multa <span class="text-danger">*</span></label>
                <select class="municipal-form-control" v-model="parametrosMulta.tipo_multa">
                  <option value="">Seleccione...</option>
                  <option value="FALTA_PAGO">Falta de Pago</option>
                  <option value="INCUMPLIMIENTO">Incumplimiento de Contrato</option>
                  <option value="DISPOSICION_IRREGULAR">Disposición Irregular</option>
                  <option value="FALTA_CONTENEDOR">Falta de Contenedor</option>
                  <option value="RECOLECCION_NO_AUTORIZADA">Recolección No Autorizada</option>
                  <option value="OTRA">Otra</option>
                </select>
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Gravedad <span class="text-danger">*</span></label>
                <select class="municipal-form-control" v-model="parametrosMulta.gravedad">
                  <option value="">Seleccione...</option>
                  <option value="LEVE">Leve (10% del adeudo)</option>
                  <option value="MODERADA">Moderada (25% del adeudo)</option>
                  <option value="GRAVE">Grave (50% del adeudo)</option>
                  <option value="MUY_GRAVE">Muy Grave (100% del adeudo)</option>
                  <option value="PERSONALIZADO">Personalizado</option>
                </select>
              </div>
            </div>

            <div class="form-row" v-if="parametrosMulta.gravedad === 'PERSONALIZADO'">
              <div class="form-group">
                <label class="municipal-form-label">Monto de la Multa <span class="text-danger">*</span></label>
                <div class="input-group">
                  <span class="input-group-text">$</span>
                  <input
                    type="number"
                    class="municipal-form-control text-end"
                    v-model.number="parametrosMulta.monto_multa"
                    min="0"
                    step="0.01"
                  />
                </div>
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Porcentaje <span class="text-muted">(opcional)</span></label>
                <div class="input-group">
                  <input
                    type="number"
                    class="municipal-form-control text-end"
                    v-model.number="parametrosMulta.porcentaje"
                    min="0"
                    max="100"
                    step="1"
                  />
                  <span class="input-group-text">%</span>
                </div>
              </div>
            </div>

            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label">Fecha de la Infracción <span class="text-danger">*</span></label>
                <input
                  type="date"
                  class="municipal-form-control"
                  v-model="parametrosMulta.fecha_infraccion"
                  :max="fechaActual"
                />
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Número de Acta <span class="text-muted">(opcional)</span></label>
                <input
                  type="text"
                  class="municipal-form-control"
                  v-model="parametrosMulta.num_acta"
                  placeholder="Ej: ACTA-2024-001"
                />
              </div>
            </div>

            <div class="form-group">
              <label class="municipal-form-label">Descripción de la Infracción <span class="text-danger">*</span></label>
              <textarea
                class="municipal-form-control"
                v-model="parametrosMulta.descripcion"
                rows="3"
                placeholder="Describa detalladamente la infracción..."
              ></textarea>
            </div>

            <div class="form-group">
              <label class="municipal-form-label">Observaciones <span class="text-muted">(opcional)</span></label>
              <textarea
                class="municipal-form-control"
                v-model="parametrosMulta.observaciones"
                rows="2"
                placeholder="Observaciones adicionales..."
              ></textarea>
            </div>

            <div class="form-group">
              <label class="municipal-form-label">Fundamento Legal</label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="parametrosMulta.fundamento_legal"
                placeholder="Ej: Art. 42, Fracc. III del Reglamento Municipal"
              />
            </div>

            <div class="form-row">
              <div class="form-group">
                <div class="municipal-checkbox">
                  <input
                    type="checkbox"
                    v-model="parametrosMulta.genera_adeudo"
                    id="generaAdeudo"
                  />
                  <label for="generaAdeudo">
                    Generar como adeudo inmediato
                  </label>
                </div>
              </div>
              <div class="form-group">
                <div class="municipal-checkbox">
                  <input
                    type="checkbox"
                    v-model="parametrosMulta.notificar"
                    id="notificar"
                  />
                  <label for="notificar">
                    Generar notificación al contribuyente
                  </label>
                </div>
              </div>
            </div>

            <!-- Vista Previa del Monto -->
            <div class="alert-warning mb-3" v-if="montoMultaCalculado > 0">
              <h6>
                <font-awesome-icon icon="calculator" />
                Monto de la Multa
              </h6>
              <div class="info-grid">
                <div class="info-item">
                  <strong>Base de Cálculo:</strong><br>
                  <span class="fs-5">${{ formatCurrency(baseCalculo) }}</span>
                </div>
                <div class="info-item">
                  <strong>Porcentaje Aplicado:</strong><br>
                  <span class="fs-5">{{ porcentajeAplicado }}%</span>
                </div>
                <div class="info-item">
                  <strong>Monto Total:</strong><br>
                  <span class="fs-4 text-danger">${{ formatCurrency(montoMultaCalculado) }}</span>
                </div>
              </div>
            </div>

            <div class="button-group">
              <button class="btn-municipal-secondary" @click="paso = 1">
                <font-awesome-icon icon="arrow-left" />
                Regresar
              </button>
              <button class="btn-municipal-primary" @click="paso = 3" :disabled="!validarParametrosMulta">
                <font-awesome-icon icon="arrow-right" />
                Vista Previa
              </button>
            </div>
          </div>
        </div>

        <!-- Paso 3: Vista Previa y Confirmación -->
        <div v-if="paso === 3" class="municipal-card">
          <div class="municipal-card-header bg-danger">
            <h5>Paso 3: Vista Previa y Confirmación</h5>
          </div>
          <div class="municipal-card-body">
            <div class="alert-warning">
              <font-awesome-icon icon="exclamation-triangle" />
              <strong>ADVERTENCIA:</strong> Está a punto de aplicar una multa. Verifique cuidadosamente la información.
            </div>

            <!-- Resumen Completo -->
            <div class="form-row">
              <div class="form-group">
                <div class="municipal-card">
                  <div class="municipal-card-header">
                    <strong>Datos del Contrato</strong>
                  </div>
                  <div class="municipal-card-body">
                    <p><strong>Número de Contrato:</strong> {{ contratoSeleccionado.num_contrato }}</p>
                    <p><strong>Control:</strong> {{ contratoSeleccionado.control_contrato }}</p>
                    <p><strong>Contribuyente:</strong> {{ contratoSeleccionado.contribuyente }}</p>
                    <p><strong>Domicilio:</strong> {{ contratoSeleccionado.domicilio }}</p>
                    <p class="mb-0"><strong>Tipo:</strong> {{ formatTipoAseo(contratoSeleccionado.tipo_aseo) }}</p>
                  </div>
                </div>
              </div>
              <div class="form-group">
                <div class="municipal-card">
                  <div class="municipal-card-header">
                    <strong>Datos de la Multa</strong>
                  </div>
                  <div class="municipal-card-body">
                    <p><strong>Tipo:</strong> {{ formatTipoMulta(parametrosMulta.tipo_multa) }}</p>
                    <p><strong>Gravedad:</strong> {{ formatGravedad(parametrosMulta.gravedad) }}</p>
                    <p><strong>Fecha Infracción:</strong> {{ formatFecha(parametrosMulta.fecha_infraccion) }}</p>
                    <p><strong>Acta:</strong> {{ parametrosMulta.num_acta || 'N/A' }}</p>
                    <p class="mb-0"><strong>Monto:</strong>
                      <span class="text-danger fs-5">${{ formatCurrency(montoMultaCalculado) }}</span>
                    </p>
                  </div>
                </div>
              </div>
            </div>

            <div class="municipal-card mb-3">
              <div class="municipal-card-header">
                <strong>Descripción de la Infracción</strong>
              </div>
              <div class="municipal-card-body">
                <p>{{ parametrosMulta.descripcion }}</p>
                <p v-if="parametrosMulta.observaciones" class="mb-0">
                  <strong>Observaciones:</strong> {{ parametrosMulta.observaciones }}
                </p>
              </div>
            </div>

            <div class="municipal-card mb-3" v-if="parametrosMulta.fundamento_legal">
              <div class="municipal-card-header">
                <strong>Fundamento Legal</strong>
              </div>
              <div class="municipal-card-body">
                <p class="mb-0">{{ parametrosMulta.fundamento_legal }}</p>
              </div>
            </div>

            <div class="alert-info mb-3">
              <h6>Acciones Adicionales:</h6>
              <ul class="mb-0">
                <li v-if="parametrosMulta.genera_adeudo">
                  <font-awesome-icon icon="check" class="text-success" />
                  Se generará como adeudo inmediato
                </li>
                <li v-if="parametrosMulta.notificar">
                  <font-awesome-icon icon="check" class="text-success" />
                  Se generará notificación al contribuyente
                </li>
                <li v-if="!parametrosMulta.genera_adeudo && !parametrosMulta.notificar">
                  <font-awesome-icon icon="info-circle" class="text-muted" />
                  Solo se registrará la multa sin acciones adicionales
                </li>
              </ul>
            </div>

            <div class="button-group">
              <button class="btn-municipal-secondary" @click="paso = 2">
                <font-awesome-icon icon="arrow-left" />
                Regresar
              </button>
              <button class="btn-municipal-secondary" @click="confirmarAplicacion" :disabled="aplicando">
                <font-awesome-icon icon="gavel" />
                <span v-if="!aplicando">Aplicar Multa</span>
                <span v-else>
                  <span class="spinner-border spinner-border-sm"></span>
                  Aplicando...
                </span>
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- Tab: Consulta de Multas -->
      <div v-if="tabActual === 'consulta'">
        <div class="municipal-card">
          <div class="municipal-card-header">
            <h5>Consulta de Multas Aplicadas</h5>
          </div>
          <div class="municipal-card-body">
            <!-- Filtros de búsqueda -->
            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label">Fecha Desde</label>
                <input type="date" class="municipal-form-control" v-model="filtrosConsulta.fecha_desde" />
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Fecha Hasta</label>
                <input type="date" class="municipal-form-control" v-model="filtrosConsulta.fecha_hasta" />
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Tipo de Multa</label>
                <select class="municipal-form-control" v-model="filtrosConsulta.tipo_multa">
                  <option value="">Todas</option>
                  <option value="FALTA_PAGO">Falta de Pago</option>
                  <option value="INCUMPLIMIENTO">Incumplimiento</option>
                  <option value="DISPOSICION_IRREGULAR">Disposición Irregular</option>
                  <option value="FALTA_CONTENEDOR">Falta de Contenedor</option>
                  <option value="RECOLECCION_NO_AUTORIZADA">Recolección No Autorizada</option>
                  <option value="OTRA">Otra</option>
                </select>
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Status</label>
                <select class="municipal-form-control" v-model="filtrosConsulta.status">
                  <option value="">Todos</option>
                  <option value="VIGENTE">Vigente</option>
                  <option value="PAGADA">Pagada</option>
                  <option value="CANCELADA">Cancelada</option>
                </select>
              </div>
            </div>

            <div class="form-row">
              <div class="form-group" style="flex: 3">
                <label class="municipal-form-label">Buscar</label>
                <input
                  type="text"
                  class="municipal-form-control"
                  v-model="filtrosConsulta.busqueda"
                  placeholder="Buscar por contrato, contribuyente, acta..."
                />
              </div>
              <div class="form-group">
                <label class="municipal-form-label">&nbsp;</label>
                <button class="btn-municipal-primary w-100" @click="consultarMultas" :disabled="cargando">
                  <font-awesome-icon icon="search" />
                  Consultar
                </button>
              </div>
            </div>

            <!-- Tabla de Resultados -->
            <div v-if="multasEncontradas.length > 0" class="table-container">
              <div class="table-responsive">
                <table class="municipal-table">
                  <thead class="municipal-table-header">
                    <tr>
                      <th>Folio</th>
                      <th>Fecha</th>
                      <th>Contrato</th>
                      <th>Contribuyente</th>
                      <th>Tipo Multa</th>
                      <th>Acta</th>
                      <th class="text-end">Monto</th>
                      <th>Status</th>
                      <th>Acciones</th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr v-for="multa in multasFiltradas" :key="multa.folio">
                      <td>{{ multa.folio }}</td>
                      <td>{{ formatFecha(multa.fecha_infraccion) }}</td>
                      <td>{{ multa.num_contrato }}</td>
                      <td>{{ multa.contribuyente }}</td>
                      <td>{{ formatTipoMulta(multa.tipo_multa) }}</td>
                      <td>{{ multa.num_acta || 'N/A' }}</td>
                      <td class="text-end">${{ formatCurrency(multa.monto) }}</td>
                      <td>
                        <span class="badge-danger" v-if="multa.status === 'VIGENTE'">{{ multa.status }}</span>
                        <span class="badge-success" v-else-if="multa.status === 'PAGADA'">{{ multa.status }}</span>
                        <span class="badge-secondary" v-else>{{ multa.status }}</span>
                      </td>
                      <td>
                        <button
                          class="btn-icon btn-info"
                          @click="verDetalleMulta(multa)"
                          title="Ver detalle"
                        >
                          <font-awesome-icon icon="eye" />
                        </button>
                        <button
                          class="btn-icon btn-danger"
                          @click="cancelarMulta(multa)"
                          v-if="multa.status === 'VIGENTE'"
                          title="Cancelar"
                        >
                          <font-awesome-icon icon="times" />
                        </button>
                      </td>
                    </tr>
                  </tbody>
                </table>
              </div>

              <!-- Resumen -->
              <div class="alert-info mt-3">
                <div class="info-grid">
                  <div class="info-item">
                    <strong>Total Multas:</strong> {{ multasEncontradas.length }}
                  </div>
                  <div class="info-item">
                    <strong>Vigentes:</strong> {{ multasVigentes }}
                  </div>
                  <div class="info-item">
                    <strong>Pagadas:</strong> {{ multasPagadas }}
                  </div>
                  <div class="info-item">
                    <strong>Monto Total:</strong> ${{ formatCurrency(montoTotalMultas) }}
                  </div>
                </div>
              </div>
            </div>

            <div v-else-if="!cargando" class="alert-warning">
              <font-awesome-icon icon="info-circle" />
              No se encontraron multas con los criterios especificados.
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal de Ayuda -->
    <DocumentationModal
      v-if="mostrarAyuda"
      :show="mostrarAyuda"
      @close="mostrarAyuda = false"
      title="Aplicación de Multas - Ayuda"
    >
      <h6>Descripción</h6>
      <p>
        Este módulo permite aplicar multas y sanciones a contratos de aseo contratado por infracciones
        al reglamento municipal o incumplimientos contractuales.
      </p>

      <h6>Tipos de Multas</h6>
      <ul>
        <li><strong>Falta de Pago:</strong> Por mora en pagos recurrentes</li>
        <li><strong>Incumplimiento:</strong> Violación a términos del contrato</li>
        <li><strong>Disposición Irregular:</strong> Manejo inadecuado de residuos</li>
        <li><strong>Falta de Contenedor:</strong> No contar con contenedor reglamentario</li>
        <li><strong>Recolección No Autorizada:</strong> Recolección fuera de horario o zona</li>
      </ul>

      <h6>Niveles de Gravedad</h6>
      <ul>
        <li><strong>Leve:</strong> 10% del adeudo base</li>
        <li><strong>Moderada:</strong> 25% del adeudo base</li>
        <li><strong>Grave:</strong> 50% del adeudo base</li>
        <li><strong>Muy Grave:</strong> 100% del adeudo base</li>
        <li><strong>Personalizado:</strong> Monto definido manualmente</li>
      </ul>

      <h6>Proceso de Aplicación</h6>
      <ol>
        <li>Buscar el contrato por número o cuenta predial</li>
        <li>Configurar tipo, gravedad y detalles de la multa</li>
        <li>Revisar vista previa y confirmar aplicación</li>
      </ol>

      <h6>Consideraciones</h6>
      <ul>
        <li>Toda multa debe tener fundamento legal documentado</li>
        <li>Se recomienda generar notificación al contribuyente</li>
        <li>Las multas pueden convertirse en adeudos inmediatos</li>
        <li>Solo personal autorizado puede aplicar multas</li>
      </ul>
    </DocumentationModal>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome'
import Swal from 'sweetalert2'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useToast } from '@/composables/useToast'

const { execute } = useApi()
const { handleError } = useLicenciasErrorHandler()
const { showToast } = useToast()

// Estado
const tabActual = ref('aplicar')
const paso = ref(1)
const cargando = ref(false)
const aplicando = ref(false)
const mostrarAyuda = ref(false)

// Búsqueda
const busqueda = ref({
  num_contrato: '',
  cuenta_predial: ''
})

// Contrato Seleccionado
const contratoSeleccionado = ref(null)

// Parámetros de la Multa
const parametrosMulta = ref({
  tipo_multa: '',
  gravedad: '',
  monto_multa: 0,
  porcentaje: 0,
  fecha_infraccion: new Date().toISOString().split('T')[0],
  num_acta: '',
  descripcion: '',
  observaciones: '',
  fundamento_legal: '',
  genera_adeudo: true,
  notificar: true
})

// Consulta
const filtrosConsulta = ref({
  fecha_desde: '',
  fecha_hasta: '',
  tipo_multa: '',
  status: '',
  busqueda: ''
})

const multasEncontradas = ref([])

// Computed
const fechaActual = computed(() => {
  return new Date().toISOString().split('T')[0]
})

const validarParametrosMulta = computed(() => {
  if (!parametrosMulta.value.tipo_multa) return false
  if (!parametrosMulta.value.gravedad) return false
  if (!parametrosMulta.value.fecha_infraccion) return false
  if (!parametrosMulta.value.descripcion) return false
  if (parametrosMulta.value.gravedad === 'PERSONALIZADO' && parametrosMulta.value.monto_multa <= 0) return false
  return true
})

const baseCalculo = computed(() => {
  // Base de cálculo: suma de adeudos pendientes o cuota mensual
  return contratoSeleccionado.value?.monto_adeudo || contratoSeleccionado.value?.cuota_mensual || 0
})

const porcentajeAplicado = computed(() => {
  if (parametrosMulta.value.gravedad === 'PERSONALIZADO') {
    return parametrosMulta.value.porcentaje || 0
  }
  switch (parametrosMulta.value.gravedad) {
    case 'LEVE': return 10
    case 'MODERADA': return 25
    case 'GRAVE': return 50
    case 'MUY_GRAVE': return 100
    default: return 0
  }
})

const montoMultaCalculado = computed(() => {
  if (parametrosMulta.value.gravedad === 'PERSONALIZADO') {
    return parametrosMulta.value.monto_multa
  }
  return (baseCalculo.value * porcentajeAplicado.value) / 100
})

const multasFiltradas = computed(() => {
  let resultado = [...multasEncontradas.value]

  if (filtrosConsulta.value.busqueda) {
    const busq = filtrosConsulta.value.busqueda.toLowerCase()
    resultado = resultado.filter(m =>
      m.num_contrato.toLowerCase().includes(busq) ||
      m.contribuyente.toLowerCase().includes(busq) ||
      (m.num_acta && m.num_acta.toLowerCase().includes(busq))
    )
  }

  return resultado
})

const multasVigentes = computed(() => {
  return multasEncontradas.value.filter(m => m.status === 'VIGENTE').length
})

const multasPagadas = computed(() => {
  return multasEncontradas.value.filter(m => m.status === 'PAGADA').length
})

const montoTotalMultas = computed(() => {
  return multasEncontradas.value.reduce((sum, m) => sum + parseFloat(m.monto || 0), 0)
})

// Métodos
const buscarContrato = async () => {
  if (!busqueda.value.num_contrato) {
    showToast('Ingrese un número de contrato', 'warning')
    return
  }

  cargando.value = true
  try {
    const response = await execute('SP_ASEO_CONTRATO_CONSULTAR', 'aseo_contratado', {
      p_num_contrato: busqueda.value.num_contrato
    })

    if (response && response.length > 0) {
      contratoSeleccionado.value = response[0]
      showToast('Contrato encontrado', 'success')
    } else {
      showToast('Contrato no encontrado', 'error')
      contratoSeleccionado.value = null
    }
  } catch (error) {
    handleError(error, 'Error al buscar contrato')
    contratoSeleccionado.value = null
  } finally {
    cargando.value = false
  }
}

const buscarPorPredial = async () => {
  if (!busqueda.value.cuenta_predial) {
    showToast('Ingrese una cuenta predial', 'warning')
    return
  }

  cargando.value = true
  try {
    const response = await execute('SP_ASEO_CONTRATO_POR_PREDIAL', 'aseo_contratado', {
      p_cuenta_predial: busqueda.value.cuenta_predial
    })

    if (response && response.length > 0) {
      contratoSeleccionado.value = response[0]
      busqueda.value.num_contrato = response[0].num_contrato
      showToast('Contrato encontrado', 'success')
    } else {
      showToast('No se encontró contrato con esa cuenta predial', 'error')
      contratoSeleccionado.value = null
    }
  } catch (error) {
    handleError(error, 'Error al buscar por cuenta predial')
    contratoSeleccionado.value = null
  } finally {
    cargando.value = false
  }
}

const confirmarAplicacion = async () => {
  const result = await Swal.fire({
    title: '¿Confirmar Aplicación de Multa?',
    html: `
      <p>Se aplicará una multa de <strong>$${formatCurrency(montoMultaCalculado.value)}</strong></p>
      <p>al contrato <strong>${contratoSeleccionado.value.num_contrato}</strong></p>
      <p class="text-muted mt-2">Esta acción quedará registrada en el sistema.</p>
    `,
    icon: 'warning',
    showCancelButton: true,
    confirmButtonColor: '#dc3545',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, Aplicar Multa',
    cancelButtonText: 'Cancelar'
  })

  if (result.isConfirmed) {
    await aplicarMulta()
  }
}

const aplicarMulta = async () => {
  aplicando.value = true
  try {
    await execute('SP_ASEO_MULTA_APLICAR', 'aseo_contratado', {
      p_control_contrato: contratoSeleccionado.value.control_contrato,
      p_tipo_multa: parametrosMulta.value.tipo_multa,
      p_gravedad: parametrosMulta.value.gravedad,
      p_monto: montoMultaCalculado.value,
      p_fecha_infraccion: parametrosMulta.value.fecha_infraccion,
      p_num_acta: parametrosMulta.value.num_acta,
      p_descripcion: parametrosMulta.value.descripcion,
      p_observaciones: parametrosMulta.value.observaciones,
      p_fundamento_legal: parametrosMulta.value.fundamento_legal,
      p_genera_adeudo: parametrosMulta.value.genera_adeudo ? 'S' : 'N',
      p_notificar: parametrosMulta.value.notificar ? 'S' : 'N'
    })

    await Swal.fire({
      title: 'Multa Aplicada',
      text: 'La multa ha sido aplicada exitosamente',
      icon: 'success',
      confirmButtonColor: '#28a745'
    })

    // Reiniciar
    contratoSeleccionado.value = null
    parametrosMulta.value = {
      tipo_multa: '',
      gravedad: '',
      monto_multa: 0,
      porcentaje: 0,
      fecha_infraccion: new Date().toISOString().split('T')[0],
      num_acta: '',
      descripcion: '',
      observaciones: '',
      fundamento_legal: '',
      genera_adeudo: true,
      notificar: true
    }
    busqueda.value = { num_contrato: '', cuenta_predial: '' }
    paso.value = 1

  } catch (error) {
    handleError(error, 'Error al aplicar multa')
  } finally {
    aplicando.value = false
  }
}

const consultarMultas = async () => {
  cargando.value = true
  try {
    const response = await execute('SP_ASEO_MULTAS_CONSULTAR', 'aseo_contratado', {
      p_fecha_desde: filtrosConsulta.value.fecha_desde || null,
      p_fecha_hasta: filtrosConsulta.value.fecha_hasta || null,
      p_tipo_multa: filtrosConsulta.value.tipo_multa || null,
      p_status: filtrosConsulta.value.status || null
    })

    multasEncontradas.value = response || []
    showToast(`${multasEncontradas.value.length} multa(s) encontrada(s)`, 'success')
  } catch (error) {
    handleError(error, 'Error al consultar multas')
    multasEncontradas.value = []
  } finally {
    cargando.value = false
  }
}

const verDetalleMulta = async (multa) => {
  await Swal.fire({
    title: `Multa ${multa.folio}`,
    html: `
      <div class="text-start">
        <p><strong>Contrato:</strong> ${multa.num_contrato}</p>
        <p><strong>Contribuyente:</strong> ${multa.contribuyente}</p>
        <p><strong>Tipo:</strong> ${formatTipoMulta(multa.tipo_multa)}</p>
        <p><strong>Fecha:</strong> ${formatFecha(multa.fecha_infraccion)}</p>
        <p><strong>Acta:</strong> ${multa.num_acta || 'N/A'}</p>
        <p><strong>Monto:</strong> $${formatCurrency(multa.monto)}</p>
        <p><strong>Descripción:</strong> ${multa.descripcion}</p>
        ${multa.observaciones ? `<p><strong>Observaciones:</strong> ${multa.observaciones}</p>` : ''}
        ${multa.fundamento_legal ? `<p><strong>Fundamento:</strong> ${multa.fundamento_legal}</p>` : ''}
      </div>
    `,
    icon: 'info',
    confirmButtonText: 'Cerrar'
  })
}

const cancelarMulta = async (multa) => {
  const result = await Swal.fire({
    title: '¿Cancelar Multa?',
    html: `
      <p>Se cancelará la multa <strong>${multa.folio}</strong></p>
      <p>Monto: <strong>$${formatCurrency(multa.monto)}</strong></p>
      <textarea id="motivoCancelacion" class="municipal-form-control mt-2"
        placeholder="Motivo de cancelación (requerido)" rows="3"></textarea>
    `,
    icon: 'warning',
    showCancelButton: true,
    confirmButtonColor: '#dc3545',
    confirmButtonText: 'Sí, Cancelar',
    cancelButtonText: 'No',
    preConfirm: () => {
      const motivo = document.getElementById('motivoCancelacion').value
      if (!motivo) {
        Swal.showValidationMessage('El motivo es requerido')
      }
      return { motivo }
    }
  })

  if (result.isConfirmed) {
    try {
      await execute('SP_ASEO_MULTA_CANCELAR', 'aseo_contratado', {
        p_folio: multa.folio,
        p_motivo: result.value.motivo
      })

      showToast('Multa cancelada exitosamente', 'success')
      await consultarMultas()
    } catch (error) {
      handleError(error, 'Error al cancelar multa')
    }
  }
}

// Formatters
const formatTipoAseo = (tipo) => {
  const tipos = {
    'D': 'Doméstico',
    'C': 'Comercial',
    'I': 'Industrial',
    'S': 'Servicios',
    'E': 'Especial'
  }
  return tipos[tipo] || tipo
}

const formatTipoMulta = (tipo) => {
  const tipos = {
    'FALTA_PAGO': 'Falta de Pago',
    'INCUMPLIMIENTO': 'Incumplimiento',
    'DISPOSICION_IRREGULAR': 'Disposición Irregular',
    'FALTA_CONTENEDOR': 'Falta de Contenedor',
    'RECOLECCION_NO_AUTORIZADA': 'Recolección No Autorizada',
    'OTRA': 'Otra'
  }
  return tipos[tipo] || tipo
}

const formatGravedad = (gravedad) => {
  const gravedades = {
    'LEVE': 'Leve (10%)',
    'MODERADA': 'Moderada (25%)',
    'GRAVE': 'Grave (50%)',
    'MUY_GRAVE': 'Muy Grave (100%)',
    'PERSONALIZADO': 'Personalizado'
  }
  return gravedades[gravedad] || gravedad
}

const formatCurrency = (value) => {
  return new Intl.NumberFormat('es-MX', {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2
  }).format(value || 0)
}

const formatFecha = (fecha) => {
  if (!fecha) return 'N/A'
  return new Date(fecha).toLocaleDateString('es-MX')
}
</script>

