<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="percent" />
      </div>
      <div class="module-view-info">
        <h1>Descuentos por Pronto Pago</h1>
        <p>Aseo Contratado - Configuración y aplicación de descuentos por pago anticipado</p>
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

    <!-- Tabs -->
    <div class="municipal-tabs">
      <button
          class="municipal-tab"
          :class="{ active: tabActual === 'configuracion' }"
          @click="tabActual = 'configuracion'"
        >
          <font-awesome-icon icon="sliders" />
          Configuración
        </button>
      <button
          class="municipal-tab"
          :class="{ active: tabActual === 'aplicar' }"
          @click="tabActual = 'aplicar'"
        >
          <font-awesome-icon icon="hand-holding-dollar" />
          Aplicar Descuento
        </button>
      <button
          class="municipal-tab"
          :class="{ active: tabActual === 'consulta' }"
          @click="tabActual = 'consulta'"
        >
          <font-awesome-icon icon="list" />
          Consultar Descuentos
        </button>
    </div>

    <!-- Tab: Configuración de Descuentos -->
    <div v-if="tabActual === 'configuracion'">
      <div class="row">
        <!-- Lista de Configuraciones Existentes -->
        <div class="col-md-5">
          <div class="municipal-card">
            <div class="municipal-card-header">
        <h5>Configuraciones Activas</h5>
            </div>
<div class="municipal-card-body">
              <div v-if="configuraciones.length > 0">
                <div
                  v-for="config in configuraciones"
                  :key="config.id"
                  class="config-item p-3 mb-2 border rounded"
                  :class="{ 'border-primary bg-light': configSeleccionada?.id === config.id }"
                  @click="seleccionarConfig(config)"
                  style="cursor: pointer;"
                >
                  <div class="d-flex justify-content-between align-items-start">
                    <div>
                      <h6 class="mb-1">{{ config.nombre }}</h6>
                      <p class="mb-1 text-muted small">{{ config.descripcion }}</p>
                      <div class="mt-2">
                        <span class="badge bg-success me-1">{{ config.porcentaje }}% descuento</span>
                        <span class="badge badge-info">{{ config.dias_anticipacion }} días</span>
                      </div>
                    </div>
                    <div>
                      <span class="badge" :class="config.activo ? 'bg-success' : 'bg-secondary'">
                        {{ config.activo ? 'Activo' : 'Inactivo' }}
                      </span>
                    </div>
                  </div>
                </div>
              </div>
              <div v-else class="alert alert-info mb-0">
                <font-awesome-icon icon="info-circle" class="me-2" />
                No hay configuraciones registradas
              </div>

              <button class="btn-municipal-primary w-100 mt-3" @click="nuevaConfiguracion">
                <font-awesome-icon icon="plus" class="me-1" />
                Nueva Configuración
              </button>
            </div>
          </div>
        </div>

        <!-- Formulario de Configuración -->
        <div class="col-md-7">
          <div class="municipal-card">
            <div class="municipal-card-header">
        <h5>
                {{ modoEdicion ? 'Editar Configuración' : 'Nueva Configuración' }}
              </h5>
            </div>
            <div class="municipal-card-body">
              <div class="form-group">
                <label class="municipal-form-label">Nombre de la Configuración <span class="text-danger">*</span></label>
                <input
                  type="text"
                  class="municipal-form-control"
                  v-model="formConfig.nombre"
                  placeholder="Ej: Descuento Anual 2024"
                />
              </div>

              <div class="form-group">
                <label class="municipal-form-label">Descripción</label>
                <textarea
                  class="municipal-form-control"
                  v-model="formConfig.descripcion"
                  rows="2"
                  placeholder="Descripción del esquema de descuento..."
                ></textarea>
              </div>

              <div class="row">
                <div class="col-md-6">
                  <div class="form-group">
                    <label class="municipal-form-label">Porcentaje de Descuento <span class="text-danger">*</span></label>
                    <div class="input-group">
                      <input
                        type="number"
                        class="municipal-form-control text-end"
                        v-model.number="formConfig.porcentaje"
                        min="0"
                        max="100"
                        step="0.5"
                      />
                      <span class="input-group-text">%</span>
                    </div>
                    <small class="form-text text-muted">Descuento aplicable sobre el total del adeudo</small>
                  </div>
                </div>
                <div class="col-md-4">
                  <div class="form-group">
                    <label class="municipal-form-label">Días de Anticipación <span class="text-danger">*</span></label>
                    <input
                      type="number"
                      class="municipal-form-control"
                      v-model.number="formConfig.dias_anticipacion"
                      min="0"
                      placeholder="30"
                    />
                    <small class="form-text text-muted">Días previos al vencimiento para aplicar descuento</small>
                  </div>
                </div>
              </div>

              <div class="row">
                <div class="col-md-6">
                  <div class="form-group">
                    <label class="municipal-form-label">Vigencia Desde</label>
                    <input
                      type="date"
                      class="municipal-form-control"
                      v-model="formConfig.vigencia_desde"
                    />
                  </div>
                </div>
                <div class="col-md-6">
                  <div class="form-group">
                    <label class="municipal-form-label">Vigencia Hasta</label>
                    <input
                      type="date"
                      class="municipal-form-control"
                      v-model="formConfig.vigencia_hasta"
                      :min="formConfig.vigencia_desde"
                    />
                  </div>
                </div>
              </div>

              <div class="form-group">
                <label class="municipal-form-label">Aplicable a</label>
                <div class="border rounded p-3">
                  <div class="form-check mb-2">
                    <input
                      class="form-check-input"
                      type="checkbox"
                      v-model="formConfig.aplica_cuota_base"
                      id="aplicaCuotaBase"
                    />
                    <label class="form-check-label" for="aplicaCuotaBase">
                      Cuota Base
                    </label>
                  </div>
                  <div class="form-check mb-2">
                    <input
                      class="form-check-input"
                      type="checkbox"
                      v-model="formConfig.aplica_recargos"
                      id="aplicaRecargos"
                    />
                    <label class="form-check-label" for="aplicaRecargos">
                      Recargos
                    </label>
                  </div>
                  <div class="form-check">
                    <input
                      class="form-check-input"
                      type="checkbox"
                      v-model="formConfig.aplica_gastos"
                      id="aplicaGastos"
                    />
                    <label class="form-check-label" for="aplicaGastos">
                      Gastos de Cobranza
                    </label>
                  </div>
                </div>
              </div>

              <div class="form-group">
                <label class="municipal-form-label">Tipo de Aseo Aplicable</label>
                <select class="municipal-form-control" v-model="formConfig.tipo_aseo">
                  <option value="">Todos</option>
                  <option value="D">Doméstico</option>
                  <option value="C">Comercial</option>
                  <option value="I">Industrial</option>
                  <option value="S">Servicios</option>
                  <option value="E">Especial</option>
                </select>
              </div>

              <div class="form-check mb-3">
                <input
                  class="form-check-input"
                  type="checkbox"
                  v-model="formConfig.activo"
                  id="activo"
                />
                <label class="form-check-label" for="activo">
                  Configuración activa
                </label>
              </div>

              <div class="form-check mb-3">
                <input
                  class="form-check-input"
                  type="checkbox"
                  v-model="formConfig.requiere_autorizacion"
                  id="requiereAutorizacion"
                />
                <label class="form-check-label" for="requiereAutorizacion">
                  Requiere autorización para aplicar
                </label>
              </div>

              <!-- Vista Previa del Descuento -->
              <div v-if="formConfig.porcentaje > 0" class="alert alert-success">
                <h6 class="alert-heading">
                  <font-awesome-icon icon="calculator" class="me-2" />
                  Ejemplo de Aplicación
                </h6>
                <p class="mb-1">
                  <strong>Adeudo de $1,000.00:</strong> Descuento de ${{ formatCurrency(1000 * formConfig.porcentaje / 100) }}
                  = <strong>${{ formatCurrency(1000 - (1000 * formConfig.porcentaje / 100)) }}</strong>
                </p>
              </div>

              <div class="d-flex gap-2">
                <button
                  class="btn-municipal-primary"
                  @click="guardarConfiguracion"
                  :disabled="!validarFormConfig || guardando"
                >
                  <font-awesome-icon icon="save" class="me-1" />
                  <span v-if="!guardando">{{ modoEdicion ? 'Actualizar' : 'Guardar' }}</span>
                  <span v-else>
                    <span class="spinner-border spinner-border-sm me-1"></span>
                    Guardando...
                  </span>
                </button>
                <button
                  class="btn-municipal-secondary"
                  @click="cancelarEdicion"
                  v-if="modoEdicion"
                >
                  <font-awesome-icon icon="times" class="me-1" />
                  Cancelar
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Tab: Aplicar Descuento -->
    <div v-if="tabActual === 'aplicar'">
      <div class="municipal-card">
        <div class="municipal-card-header">
        <h5>Aplicar Descuento a Adeudo</h5>
        </div>
        <div class="municipal-card-body">
          <!-- Búsqueda de Contrato -->
          <div class="row mb-4">
            <div class="col-md-4">
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
                    <font-awesome-icon icon="search" class="me-1" />
                    Buscar
                  </button>
                </div>
              </div>
            </div>
          </div>

          <!-- Datos del Contrato -->
          <div v-if="contratoSeleccionado" class="alert alert-info mb-4">
            <h6 class="alert-heading">
              <font-awesome-icon icon="check-circle" class="me-2" />
              Contrato Encontrado
            </h6>
            <div class="row">
              <div class="col-md-4">
                <strong>Contrato:</strong> {{ contratoSeleccionado.num_contrato }}<br>
                <strong>Contribuyente:</strong> {{ contratoSeleccionado.contribuyente }}
              </div>
              <div class="col-md-4">
                <strong>Tipo:</strong> {{ formatTipoAseo(contratoSeleccionado.tipo_aseo) }}<br>
                <strong>Status:</strong>
                <span class="badge" :class="contratoSeleccionado.status === 'A' ? 'bg-success' : 'bg-danger'">
                  {{ contratoSeleccionado.status === 'A' ? 'Activo' : 'Inactivo' }}
                </span>
              </div>
              <div class="col-md-4">
                <strong>Adeudos Pendientes:</strong> {{ adeudosDisponibles.length }}<br>
                <strong>Total Adeudo:</strong> <span class="text-danger">${{ formatCurrency(totalAdeudo) }}</span>
              </div>
            </div>
          </div>

          <!-- Adeudos Disponibles -->
          <div v-if="adeudosDisponibles.length > 0">
            <h6 class="mb-3">
              <font-awesome-icon icon="list" class="me-2" />
              Adeudos Disponibles
            </h6>
            <div class="table-responsive mb-4">
              <table class="municipal-table">
                <thead>
                  <tr>
                    <th>
                      <input
                        type="checkbox"
                        v-model="todosMarcados"
                        @change="toggleTodos"
                      />
                    </th>
                    <th>Folio</th>
                    <th>Periodo</th>
                    <th>Fecha Vencimiento</th>
                    <th class="text-end">Cuota Base</th>
                    <th class="text-end">Recargos</th>
                    <th class="text-end">Gastos</th>
                    <th class="text-end">Total</th>
                    <th>Desc. Aplicable</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="adeudo in adeudosDisponibles" :key="adeudo.folio">
                    <td>
                      <input
                        type="checkbox"
                        :value="adeudo.folio"
                        v-model="adeudosSeleccionados"
                      />
                    </td>
                    <td>{{ adeudo.folio }}</td>
                    <td>{{ adeudo.periodo }}</td>
                    <td>{{ formatFecha(adeudo.fecha_vencimiento) }}</td>
                    <td class="text-end">${{ formatCurrency(adeudo.cuota_base) }}</td>
                    <td class="text-end">${{ formatCurrency(adeudo.recargos) }}</td>
                    <td class="text-end">${{ formatCurrency(adeudo.gastos_cobranza) }}</td>
                    <td class="text-end"><strong>${{ formatCurrency(adeudo.total_periodo) }}</strong></td>
                    <td>
                      <span
                        v-if="descuentoAplicable(adeudo)"
                        class="badge badge-success"
                        :title="descuentoAplicable(adeudo).nombre"
                      >
                        {{ descuentoAplicable(adeudo).porcentaje }}%
                      </span>
                      <span v-else class="badge badge-secondary">N/A</span>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>

            <!-- Selección de Configuración de Descuento -->
            <div v-if="adeudosSeleccionados.length > 0" class="municipal-card mb-3 border-success">
              <div class="municipal-card-header">
                <strong>Aplicar Descuento a {{ adeudosSeleccionados.length }} Adeudo(s)</strong>
              </div>
              <div class="municipal-card-body">
                <div class="form-group">
                  <label class="municipal-form-label">Configuración de Descuento <span class="text-danger">*</span></label>
                  <select class="municipal-form-control" v-model="descuentoSeleccionado">
                    <option value="">Seleccione una configuración...</option>
                    <option
                      v-for="config in configuracionesActivas"
                      :key="config.id"
                      :value="config.id"
                    >
                      {{ config.nombre }} - {{ config.porcentaje }}%
                    </option>
                  </select>
                </div>

                <div v-if="descuentoSeleccionado" class="alert alert-info">
                  <h6>Resumen del Descuento:</h6>
                  <div class="row">
                    <div class="col-md-3">
                      <strong>Total Original:</strong><br>
                      <span class="fs-5">${{ formatCurrency(totalSeleccionado) }}</span>
                    </div>
                    <div class="col-md-3">
                      <strong>Descuento:</strong><br>
                      <span class="fs-5 text-success">- ${{ formatCurrency(montoDescuento) }}</span>
                    </div>
                    <div class="col-md-3">
                      <strong>Total a Pagar:</strong><br>
                      <span class="fs-4 text-primary">${{ formatCurrency(totalConDescuento) }}</span>
                    </div>
                    <div class="col-md-3">
                      <strong>Ahorro:</strong><br>
                      <span class="fs-5 text-success">{{ porcentajeDescuentoAplicado }}%</span>
                    </div>
                  </div>
                </div>

                <div class="form-group" v-if="configuracionRequiereAutorizacion">
                  <label class="municipal-form-label">Autorizado Por <span class="text-danger">*</span></label>
                  <input
                    type="text"
                    class="municipal-form-control"
                    v-model="autorizacion.autorizado_por"
                    placeholder="Nombre del funcionario autorizante"
                  />
                </div>

                <div class="form-group" v-if="configuracionRequiereAutorizacion">
                  <label class="municipal-form-label">Número de Oficio/Autorización</label>
                  <input
                    type="text"
                    class="municipal-form-control"
                    v-model="autorizacion.num_oficio"
                    placeholder="Ej: OFICIO-2024-001"
                  />
                </div>

                <div class="form-group">
                  <label class="municipal-form-label">Observaciones</label>
                  <textarea
                    class="municipal-form-control"
                    v-model="autorizacion.observaciones"
                    rows="2"
                    placeholder="Observaciones sobre la aplicación del descuento..."
                  ></textarea>
                </div>

                <button
                  class="btn-municipal-primary"
                  @click="confirmarAplicacion"
                  :disabled="!descuentoSeleccionado || aplicando || (configuracionRequiereAutorizacion && !autorizacion.autorizado_por)"
                >
                  <font-awesome-icon icon="check" class="me-1" />
                  <span v-if="!aplicando">Aplicar Descuento</span>
                  <span v-else>
                    <span class="spinner-border spinner-border-sm me-1"></span>
                    Aplicando...
                  </span>
                </button>
              </div>
            </div>
          </div>

          <div v-else-if="contratoSeleccionado && adeudosDisponibles.length === 0" class="alert alert-success">
            <font-awesome-icon icon="check-circle" class="me-2" />
            Este contrato no tiene adeudos pendientes.
          </div>
        </div>
      </div>
    </div>

    <!-- Tab: Consulta de Descuentos Aplicados -->
    <div v-if="tabActual === 'consulta'">
      <div class="municipal-card">
        <div class="municipal-card-header">
        <h5>Consulta de Descuentos Aplicados</h5>
        </div>
        <div class="municipal-card-body">
          <!-- Filtros de búsqueda -->
          <div class="row mb-3">
            <div class="col-md-3">
              <div class="form-group">
                <label class="municipal-form-label">Fecha Desde</label>
                <input type="date" class="municipal-form-control" v-model="filtrosConsulta.fecha_desde" />
              </div>
            </div>
            <div class="col-md-3">
              <div class="form-group">
                <label class="municipal-form-label">Fecha Hasta</label>
                <input type="date" class="municipal-form-control" v-model="filtrosConsulta.fecha_hasta" />
              </div>
            </div>
            <div class="col-md-3">
              <div class="form-group">
                <label class="municipal-form-label">Configuración</label>
                <select class="municipal-form-control" v-model="filtrosConsulta.config_id">
                  <option value="">Todas</option>
                  <option v-for="config in configuraciones" :key="config.id" :value="config.id">
                    {{ config.nombre }}
                  </option>
                </select>
              </div>
            </div>
            <div class="col-md-3">
              <label class="municipal-form-label">&nbsp;</label>
              <button class="btn-municipal-primary w-100" @click="consultarDescuentos" :disabled="cargando">
                <font-awesome-icon icon="search" class="me-1" />
                Consultar
              </button>
            </div>
          </div>

          <!-- Resultados -->
          <div v-if="descuentosAplicados.length > 0">
            <div class="table-responsive">
              <table class="municipal-table">
                <thead>
                  <tr>
                    <th>Fecha</th>
                    <th>Contrato</th>
                    <th>Contribuyente</th>
                    <th>Configuración</th>
                    <th>Adeudos</th>
                    <th class="text-end">Monto Original</th>
                    <th class="text-end">Descuento</th>
                    <th class="text-end">Total Final</th>
                    <th>Autorizado Por</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="desc in descuentosAplicados" :key="desc.id">
                    <td>{{ formatFecha(desc.fecha_aplicacion) }}</td>
                    <td>{{ desc.num_contrato }}</td>
                    <td>{{ desc.contribuyente }}</td>
                    <td>{{ desc.nombre_config }}</td>
                    <td>{{ desc.num_adeudos }}</td>
                    <td class="text-end">${{ formatCurrency(desc.monto_original) }}</td>
                    <td class="text-end text-success">- ${{ formatCurrency(desc.monto_descuento) }}</td>
                    <td class="text-end"><strong>${{ formatCurrency(desc.total_final) }}</strong></td>
                    <td>{{ desc.autorizado_por || 'N/A' }}</td>
                  </tr>
                </tbody>
              </table>
            </div>

            <!-- Resumen -->
            <div class="alert alert-info mt-3">
              <div class="row">
                <div class="col-md-3">
                  <strong>Total Registros:</strong> {{ descuentosAplicados.length }}
                </div>
                <div class="col-md-3">
                  <strong>Monto Original:</strong> ${{ formatCurrency(totalMontoOriginal) }}
                </div>
                <div class="col-md-3">
                  <strong>Total Descuentos:</strong> ${{ formatCurrency(totalDescuentosOtorgados) }}
                </div>
                <div class="col-md-3">
                  <strong>Monto Final:</strong> ${{ formatCurrency(totalMontoFinal) }}
                </div>
              </div>
            </div>
          </div>

          <div v-else-if="!cargando" class="alert alert-warning">
            <font-awesome-icon icon="info-circle" class="me-2" />
            No se encontraron descuentos aplicados con los criterios especificados.
          </div>
        </div>
      </div>
    </div>

    <!-- Modal de Ayuda -->

    <DocumentationModal
      v-if="mostrarAyuda"
      :show="mostrarAyuda"
      @close="mostrarAyuda = false"
      title="Descuentos por Pronto Pago - Ayuda"
    >
      <h6>Descripción</h6>
      <p>
        Este módulo permite configurar y aplicar esquemas de descuento por pronto pago,
        incentivando a los contribuyentes a liquidar sus adeudos de manera anticipada.
      </p>

      <h6>Configuración de Descuentos</h6>
      <p>Cada configuración define:</p>
      <ul>
        <li><strong>Porcentaje:</strong> El descuento aplicable (ej: 10%, 15%)</li>
        <li><strong>Días de Anticipación:</strong> Cuántos días antes del vencimiento aplica</li>
        <li><strong>Vigencia:</strong> Periodo durante el cual está activa la configuración</li>
        <li><strong>Aplicabilidad:</strong> A qué conceptos aplica (cuota base, recargos, gastos)</li>
      </ul>

      <h6>Aplicación de Descuentos</h6>
      <ol>
        <li>Buscar el contrato con adeudos pendientes</li>
        <li>Seleccionar los adeudos elegibles</li>
        <li>Elegir la configuración de descuento apropiada</li>
        <li>Revisar el cálculo y confirmar aplicación</li>
      </ol>

      <h6>Consideraciones</h6>
      <ul>
        <li>Solo se aplican descuentos a adeudos no vencidos o con anticipación configurada</li>
        <li>Algunas configuraciones requieren autorización expresa</li>
        <li>Los descuentos quedan registrados para auditoría</li>
        <li>Una vez aplicado, el descuento se refleja en el monto a pagar</li>
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
const tabActual = ref('configuracion')
const cargando = ref(false)
const guardando = ref(false)
const aplicando = ref(false)
const mostrarAyuda = ref(false)
const modoEdicion = ref(false)

// Configuraciones
const configuraciones = ref([])
const configSeleccionada = ref(null)
const formConfig = ref({
  nombre: '',
  descripcion: '',
  porcentaje: 0,
  dias_anticipacion: 30,
  vigencia_desde: '',
  vigencia_hasta: '',
  aplica_cuota_base: true,
  aplica_recargos: true,
  aplica_gastos: true,
  tipo_aseo: '',
  activo: true,
  requiere_autorizacion: false
})

// Aplicación de Descuentos
const busqueda = ref({
  num_contrato: ''
})
const contratoSeleccionado = ref(null)
const adeudosDisponibles = ref([])
const adeudosSeleccionados = ref([])
const todosMarcados = ref(false)
const descuentoSeleccionado = ref('')
const autorizacion = ref({
  autorizado_por: '',
  num_oficio: '',
  observaciones: ''
})

// Consulta
const filtrosConsulta = ref({
  fecha_desde: '',
  fecha_hasta: '',
  config_id: ''
})
const descuentosAplicados = ref([])

// Computed
const validarFormConfig = computed(() => {
  return formConfig.value.nombre &&
         formConfig.value.porcentaje > 0 &&
         formConfig.value.dias_anticipacion >= 0
})

const configuracionesActivas = computed(() => {
  return configuraciones.value.filter(c => c.activo)
})

const totalAdeudo = computed(() => {
  return adeudosDisponibles.value.reduce((sum, a) => sum + parseFloat(a.total_periodo || 0), 0)
})

const totalSeleccionado = computed(() => {
  return adeudosDisponibles.value
    .filter(a => adeudosSeleccionados.value.includes(a.folio))
    .reduce((sum, a) => sum + parseFloat(a.total_periodo || 0), 0)
})

const configuracionDescuento = computed(() => {
  if (!descuentoSeleccionado.value) return null
  return configuraciones.value.find(c => c.id === descuentoSeleccionado.value)
})

const montoDescuento = computed(() => {
  if (!configuracionDescuento.value) return 0

  let monto = 0
  const adeudos = adeudosDisponibles.value.filter(a => adeudosSeleccionados.value.includes(a.folio))

  adeudos.forEach(adeudo => {
    if (configuracionDescuento.value.aplica_cuota_base) {
      monto += parseFloat(adeudo.cuota_base || 0) * configuracionDescuento.value.porcentaje / 100
    }
    if (configuracionDescuento.value.aplica_recargos) {
      monto += parseFloat(adeudo.recargos || 0) * configuracionDescuento.value.porcentaje / 100
    }
    if (configuracionDescuento.value.aplica_gastos) {
      monto += parseFloat(adeudo.gastos_cobranza || 0) * configuracionDescuento.value.porcentaje / 100
    }
  })

  return monto
})

const totalConDescuento = computed(() => {
  return totalSeleccionado.value - montoDescuento.value
})

const porcentajeDescuentoAplicado = computed(() => {
  if (totalSeleccionado.value === 0) return 0
  return ((montoDescuento.value / totalSeleccionado.value) * 100).toFixed(2)
})

const configuracionRequiereAutorizacion = computed(() => {
  return configuracionDescuento.value?.requiere_autorizacion || false
})

const totalMontoOriginal = computed(() => {
  return descuentosAplicados.value.reduce((sum, d) => sum + parseFloat(d.monto_original || 0), 0)
})

const totalDescuentosOtorgados = computed(() => {
  return descuentosAplicados.value.reduce((sum, d) => sum + parseFloat(d.monto_descuento || 0), 0)
})

const totalMontoFinal = computed(() => {
  return descuentosAplicados.value.reduce((sum, d) => sum + parseFloat(d.total_final || 0), 0)
})

// Métodos
const cargarConfiguraciones = async () => {
  try {
    const response = await execute('SP_ASEO_DESCUENTOS_CONFIG_LISTAR', 'aseo_contratado', {})
    configuraciones.value = response || []
  } catch (error) {
    handleError(error, 'Error al cargar configuraciones')
    configuraciones.value = []
  }
}

const seleccionarConfig = (config) => {
  configSeleccionada.value = config
  formConfig.value = { ...config }
  modoEdicion.value = true
}

const nuevaConfiguracion = () => {
  configSeleccionada.value = null
  formConfig.value = {
    nombre: '',
    descripcion: '',
    porcentaje: 0,
    dias_anticipacion: 30,
    vigencia_desde: '',
    vigencia_hasta: '',
    aplica_cuota_base: true,
    aplica_recargos: true,
    aplica_gastos: true,
    tipo_aseo: '',
    activo: true,
    requiere_autorizacion: false
  }
  modoEdicion.value = false
}

const guardarConfiguracion = async () => {
  guardando.value = true
  try {
    const sp = modoEdicion.value ? 'SP_ASEO_DESCUENTOS_CONFIG_ACTUALIZAR' : 'SP_ASEO_DESCUENTOS_CONFIG_INSERTAR'

    await execute(sp, 'aseo_contratado', {
      p_id: modoEdicion.value ? formConfig.value.id : undefined,
      p_nombre: formConfig.value.nombre,
      p_descripcion: formConfig.value.descripcion,
      p_porcentaje: formConfig.value.porcentaje,
      p_dias_anticipacion: formConfig.value.dias_anticipacion,
      p_vigencia_desde: formConfig.value.vigencia_desde || null,
      p_vigencia_hasta: formConfig.value.vigencia_hasta || null,
      p_aplica_cuota_base: formConfig.value.aplica_cuota_base ? 'S' : 'N',
      p_aplica_recargos: formConfig.value.aplica_recargos ? 'S' : 'N',
      p_aplica_gastos: formConfig.value.aplica_gastos ? 'S' : 'N',
      p_tipo_aseo: formConfig.value.tipo_aseo || null,
      p_activo: formConfig.value.activo ? 'S' : 'N',
      p_requiere_autorizacion: formConfig.value.requiere_autorizacion ? 'S' : 'N'
    })

    showToast('Configuración guardada exitosamente', 'success')
    await cargarConfiguraciones()
    nuevaConfiguracion()
  } catch (error) {
    handleError(error, 'Error al guardar configuración')
  } finally {
    guardando.value = false
  }
}

const cancelarEdicion = () => {
  nuevaConfiguracion()
}

const toggleTodos = () => {
  if (todosMarcados.value) {
    adeudosSeleccionados.value = adeudosDisponibles.value.map(a => a.folio)
  } else {
    adeudosSeleccionados.value = []
  }
}

const buscarContrato = async () => {
  if (!busqueda.value.num_contrato) {
    showToast('Ingrese un número de contrato', 'warning')
    return
  }

  cargando.value = true
  try {
    const responseContrato = await execute('SP_ASEO_CONTRATO_CONSULTAR', 'aseo_contratado', {
      p_num_contrato: busqueda.value.num_contrato
    })

    if (responseContrato && responseContrato.length > 0) {
      contratoSeleccionado.value = responseContrato[0]

      const responseAdeudos = await execute('SP_ASEO_ADEUDOS_PENDIENTES', 'aseo_contratado', {
        p_control_contrato: responseContrato[0].control_contrato
      })

      adeudosDisponibles.value = responseAdeudos || []
      adeudosSeleccionados.value = []

      showToast('Contrato encontrado', 'success')
    } else {
      showToast('Contrato no encontrado', 'error')
      contratoSeleccionado.value = null
      adeudosDisponibles.value = []
    }
  } catch (error) {
    handleError(error, 'Error al buscar contrato')
    contratoSeleccionado.value = null
    adeudosDisponibles.value = []
  } finally {
    cargando.value = false
  }
}

const descuentoAplicable = (adeudo) => {
  // Lógica para determinar si un adeudo tiene descuento aplicable
  const config = configuracionesActivas.value.find(c => {
    if (c.tipo_aseo && c.tipo_aseo !== contratoSeleccionado.value?.tipo_aseo) return false
    // Aquí se validaría días de anticipación y vigencia
    return true
  })
  return config || null
}

const confirmarAplicacion = async () => {
  const result = await Swal.fire({
    title: '¿Confirmar Aplicación de Descuento?',
    html: `
      <p>Se aplicará un descuento de <strong>$${formatCurrency(montoDescuento.value)}</strong></p>
      <p>a <strong>${adeudosSeleccionados.value.length}</strong> adeudo(s)</p>
      <p>Total a pagar: <strong>$${formatCurrency(totalConDescuento.value)}</strong></p>
    `,
    icon: 'question',
    showCancelButton: true,
    confirmButtonColor: '#28a745',
    confirmButtonText: 'Sí, Aplicar',
    cancelButtonText: 'Cancelar'
  })

  if (result.isConfirmed) {
    await aplicarDescuento()
  }
}

const aplicarDescuento = async () => {
  aplicando.value = true
  try {
    await execute('SP_ASEO_DESCUENTO_APLICAR', 'aseo_contratado', {
      p_control_contrato: contratoSeleccionado.value.control_contrato,
      p_config_id: descuentoSeleccionado.value,
      p_adeudos: adeudosSeleccionados.value.join(','),
      p_monto_original: totalSeleccionado.value,
      p_monto_descuento: montoDescuento.value,
      p_total_final: totalConDescuento.value,
      p_autorizado_por: autorizacion.value.autorizado_por || null,
      p_num_oficio: autorizacion.value.num_oficio || null,
      p_observaciones: autorizacion.value.observaciones || null
    })

    await Swal.fire({
      title: 'Descuento Aplicado',
      text: 'El descuento ha sido aplicado exitosamente',
      icon: 'success',
      confirmButtonColor: '#28a745'
    })

    // Reiniciar
    contratoSeleccionado.value = null
    adeudosDisponibles.value = []
    adeudosSeleccionados.value = []
    descuentoSeleccionado.value = ''
    autorizacion.value = {
      autorizado_por: '',
      num_oficio: '',
      observaciones: ''
    }
    busqueda.value.num_contrato = ''

  } catch (error) {
    handleError(error, 'Error al aplicar descuento')
  } finally {
    aplicando.value = false
  }
}

const consultarDescuentos = async () => {
  cargando.value = true
  try {
    const response = await execute('SP_ASEO_DESCUENTOS_CONSULTAR', 'aseo_contratado', {
      p_fecha_desde: filtrosConsulta.value.fecha_desde || null,
      p_fecha_hasta: filtrosConsulta.value.fecha_hasta || null,
      p_config_id: filtrosConsulta.value.config_id || null
    })

    descuentosAplicados.value = response || []
    showToast(`${descuentosAplicados.value.length} registro(s) encontrado(s)`, 'success')
  } catch (error) {
    handleError(error, 'Error al consultar descuentos')
    descuentosAplicados.value = []
  } finally {
    cargando.value = false
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

// Inicialización
cargarConfiguraciones()
</script>

