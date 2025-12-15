<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="file-contract" />
      </div>
      <div class="module-view-info">
        <h1>Gestión de Convenios de Pago</h1>
        <p>Aseo Contratado - Registro y seguimiento de convenios de pago para adeudos</p>
      </div>
      <div class="button-group ms-auto">
        <button
          class="btn-municipal-secondary"
          @click="mostrarDocumentacion"
          title="Documentacion Tecnica"
        >
          <font-awesome-icon icon="file-code" />
          Documentacion
        </button>
        <button
          class="btn-municipal-purple"
          @click="openDocumentation"
          title="Ayuda"
        >
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
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
          :class="{ active: tabActual === 'nuevo' }"
          @click="cambiarTab('nuevo')"
        >
          <font-awesome-icon icon="plus" />
          Nuevo Convenio
        </button>
      <button
          class="municipal-tab"
          :class="{ active: tabActual === 'consulta' }"
          @click="cambiarTab('consulta')"
        >
          <font-awesome-icon icon="list" />
          Consultar Convenios
        </button>
      <button
          class="municipal-tab"
          :class="{ active: tabActual === 'parcialidades' }"
          @click="cambiarTab('parcialidades')"
        >
          <font-awesome-icon icon="calendar-check" />
          Parcialidades
        </button>
    </div>    <!-- Tab: Nuevo Convenio -->
    <div v-if="tabActual === 'nuevo'">
      <!-- Paso 1: Selección de Contrato -->
      <div v-if="paso === 1" class="municipal-card">
        <div class="municipal-card-header">
        <h5>Paso 1: Selección de Contrato y Adeudos</h5>
        </div>
        <div class="municipal-card-body">
          <div class="row">
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
          <div v-if="contratoSeleccionado" class="municipal-alert municipal-alert-info">
            <h6 class="alert-heading">
              <font-awesome-icon icon="check-circle" class="me-2" />
              Contrato Encontrado
            </h6>
            <div class="row">
              <div class="col-md-4">
                <strong>Contrato:</strong> {{ contratoSeleccionado.num_contrato }}<br>
                <strong>Control:</strong> {{ contratoSeleccionado.control_contrato }}
              </div>
              <div class="col-md-4">
                <strong>Contribuyente:</strong> {{ contratoSeleccionado.contribuyente }}<br>
                <strong>RFC:</strong> {{ contratoSeleccionado.rfc || 'N/A' }}
              </div>
              <div class="col-md-4">
                <strong>Domicilio:</strong> {{ contratoSeleccionado.domicilio }}<br>
                <strong>Tipo:</strong> {{ formatTipoAseo(contratoSeleccionado.tipo_aseo) }}
              </div>
            </div>
          </div>

          <!-- Adeudos Disponibles -->
          <div v-if="contratoSeleccionado && adeudosDisponibles.length > 0" class="mt-3">
            <h6>
              <font-awesome-icon icon="exclamation-triangle" class="text-warning me-2" />
              Adeudos Disponibles para Convenio
            </h6>
            <div class="table-responsive">
              <table class="municipal-table">
                <thead class="municipal-table-header">
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
                    <th>Operación</th>
                    <th class="text-end">Cuota Base</th>
                    <th class="text-end">Recargos</th>
                    <th class="text-end">Gastos</th>
                    <th class="text-end">Total</th>
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
                    <td>{{ adeudo.cve_operacion }}</td>
                    <td class="text-end">${{ formatCurrency(adeudo.cuota_base) }}</td>
                    <td class="text-end">${{ formatCurrency(adeudo.recargos) }}</td>
                    <td class="text-end">${{ formatCurrency(adeudo.gastos_cobranza) }}</td>
                    <td class="text-end"><strong>${{ formatCurrency(adeudo.total_periodo) }}</strong></td>
                  </tr>
                </tbody>
                <tfoot>
                  <tr>
                    <td colspan="7" class="text-end"><strong>Total Seleccionado:</strong></td>
                    <td class="text-end"><strong>${{ formatCurrency(totalSeleccionado) }}</strong></td>
                  </tr>
                </tfoot>
              </table>
            </div>

            <div class="alert alert-warning mt-3" v-if="adeudosSeleccionados.length > 0">
              <font-awesome-icon icon="info-circle" class="me-2" />
              <strong>{{ adeudosSeleccionados.length }}</strong> adeudo(s) seleccionado(s) por un total de
              <strong>${{ formatCurrency(totalSeleccionado) }}</strong>
            </div>

            <div class="mt-3">
              <button
                class="btn-municipal-primary"
                @click="paso = 2"
                :disabled="adeudosSeleccionados.length === 0"
              >
                <font-awesome-icon icon="arrow-right" class="me-1" />
                Continuar
              </button>
            </div>
          </div>

          <div v-else-if="contratoSeleccionado && adeudosDisponibles.length === 0" class="alert alert-success mt-3">
            <font-awesome-icon icon="check-circle" class="me-2" />
            Este contrato no tiene adeudos pendientes.
          </div>
        </div>
      </div>

      <!-- Paso 2: Configuración del Convenio -->
      <div v-if="paso === 2" class="municipal-card">
        <div class="municipal-card-header">
        <h5>Paso 2: Configuración del Convenio</h5>
        </div>
        <div class="municipal-card-body">
          <!-- Resumen -->
          <div class="alert alert-info mb-4">
            <div class="row">
              <div class="col-md-6">
                <strong>Contrato:</strong> {{ contratoSeleccionado.num_contrato }}<br>
                <strong>Contribuyente:</strong> {{ contratoSeleccionado.contribuyente }}
              </div>
              <div class="col-md-6">
                <strong>Adeudos:</strong> {{ adeudosSeleccionados.length }}<br>
                <strong>Monto Total:</strong> <span class="fs-5 text-danger">${{ formatCurrency(totalSeleccionado) }}</span>
              </div>
            </div>
          </div>

          <div class="row">
            <div class="col-md-6">
              <div class="form-group">
                <label class="municipal-form-label">Tipo de Convenio <span class="text-danger">*</span></label>
                <select class="municipal-form-control" v-model="parametrosConvenio.tipo_convenio">
                  <option value="">Seleccione...</option>
                  <option value="PARCIALIDADES">Pago en Parcialidades</option>
                  <option value="QUITA">Quita de Recargos/Gastos</option>
                  <option value="MIXTO">Mixto (Quita + Parcialidades)</option>
                </select>
              </div>
            </div>
            <div class="col-md-6">
              <div class="form-group">
                <label class="municipal-form-label">Fecha del Convenio <span class="text-danger">*</span></label>
                <input
                  type="date"
                  class="municipal-form-control"
                  v-model="parametrosConvenio.fecha_convenio"
                  :max="fechaActual"
                />
              </div>
            </div>
          </div>

          <!-- Configuración de Quita -->
          <div v-if="parametrosConvenio.tipo_convenio === 'QUITA' || parametrosConvenio.tipo_convenio === 'MIXTO'"
               class="municipal-card mb-3">
            <div class="municipal-card-header">
              <strong>Configuración de Quita</strong>
            </div>
            <div class="municipal-card-body">
              <div class="row">
                <div class="col-md-6">
                  <div class="form-check mb-2">
                    <input
                      class="form-check-input"
                      type="checkbox"
                      v-model="parametrosConvenio.condonar_recargos"
                      id="condonarRecargos"
                    />
                    <label class="form-check-label" for="condonarRecargos">
                      Condonar Recargos ({{ porcentajeRecargos }}%)
                    </label>
                  </div>
                  <div class="form-group" v-if="parametrosConvenio.condonar_recargos">
                    <label class="municipal-form-label">Porcentaje de Condonación</label>
                    <div class="input-group">
                      <input
                        type="number"
                        class="municipal-form-control"
                        v-model.number="parametrosConvenio.porcentaje_recargos"
                        min="0"
                        max="100"
                        step="5"
                      />
                      <span class="input-group-text">%</span>
                    </div>
                  </div>
                </div>
                <div class="col-md-6">
                  <div class="form-check mb-2">
                    <input
                      class="form-check-input"
                      type="checkbox"
                      v-model="parametrosConvenio.condonar_gastos"
                      id="condonarGastos"
                    />
                    <label class="form-check-label" for="condonarGastos">
                      Condonar Gastos de Cobranza ({{ porcentajeGastos }}%)
                    </label>
                  </div>
                  <div class="form-group" v-if="parametrosConvenio.condonar_gastos">
                    <label class="municipal-form-label">Porcentaje de Condonación</label>
                    <div class="input-group">
                      <input
                        type="number"
                        class="municipal-form-control"
                        v-model.number="parametrosConvenio.porcentaje_gastos"
                        min="0"
                        max="100"
                        step="5"
                      />
                      <span class="input-group-text">%</span>
                    </div>
                  </div>
                </div>
              </div>

              <div class="municipal-alert municipal-alert-success">
                <div class="row">
                  <div class="col-md-4">
                    <strong>Recargos a Condonar:</strong><br>
                    <span class="fs-5">${{ formatCurrency(montoRecargosCondonar) }}</span>
                  </div>
                  <div class="col-md-4">
                    <strong>Gastos a Condonar:</strong><br>
                    <span class="fs-5">${{ formatCurrency(montoGastosCondonar) }}</span>
                  </div>
                  <div class="col-md-4">
                    <strong>Total a Condonar:</strong><br>
                    <span class="fs-4 text-success">${{ formatCurrency(totalCondonacion) }}</span>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- Configuración de Parcialidades -->
          <div v-if="parametrosConvenio.tipo_convenio === 'PARCIALIDADES' || parametrosConvenio.tipo_convenio === 'MIXTO'"
               class="municipal-card mb-3">
            <div class="municipal-card-header">
              <strong>Configuración de Parcialidades</strong>
            </div>
            <div class="municipal-card-body">
              <div class="row">
                <div class="col-md-4">
                  <div class="form-group">
                    <label class="municipal-form-label">Número de Parcialidades <span class="text-danger">*</span></label>
                    <select class="municipal-form-control" v-model.number="parametrosConvenio.num_parcialidades">
                      <option value="">Seleccione...</option>
                      <option value="3">3 mensualidades</option>
                      <option value="6">6 mensualidades</option>
                      <option value="12">12 mensualidades</option>
                      <option value="18">18 mensualidades</option>
                      <option value="24">24 mensualidades</option>
                      <option value="36">36 mensualidades</option>
                    </select>
                  </div>
                </div>
                <div class="col-md-4">
                  <div class="form-group">
                    <label class="municipal-form-label">Fecha Primer Pago <span class="text-danger">*</span></label>
                    <input
                      type="date"
                      class="municipal-form-control"
                      v-model="parametrosConvenio.fecha_primer_pago"
                      :min="fechaActual"
                    />
                  </div>
                </div>
                <div class="col-md-4">
                  <div class="form-group">
                    <label class="municipal-form-label">Periodicidad</label>
                    <select class="municipal-form-control" v-model="parametrosConvenio.periodicidad">
                      <option value="MENSUAL">Mensual</option>
                      <option value="QUINCENAL">Quincenal</option>
                      <option value="SEMANAL">Semanal</option>
                    </select>
                  </div>
                </div>
              </div>

              <div v-if="parametrosConvenio.num_parcialidades > 0" class="municipal-alert municipal-alert-info">
                <div class="row">
                  <div class="col-md-4">
                    <strong>Monto a Pagar:</strong><br>
                    <span class="fs-5">${{ formatCurrency(montoAPagar) }}</span>
                  </div>
                  <div class="col-md-4">
                    <strong>Parcialidad:</strong><br>
                    <span class="fs-4 text-primary">${{ formatCurrency(montoParcialidad) }}</span>
                  </div>
                  <div class="col-md-4">
                    <strong>Último Pago:</strong><br>
                    <span class="fs-6">{{ fechaUltimoPago }}</span>
                  </div>
                </div>
              </div>

              <div class="form-check mb-3">
                <input
                  class="form-check-input"
                  type="checkbox"
                  v-model="parametrosConvenio.generar_calendario"
                  id="generarCalendario"
                />
                <label class="form-check-label" for="generarCalendario">
                  Generar calendario de pagos automáticamente
                </label>
              </div>
            </div>
          </div>

          <!-- Información Adicional -->
          <div class="row">
            <div class="col-md-6">
              <div class="form-group">
                <label class="municipal-form-label">Número de Convenio</label>
                <input
                  type="text"
                  class="municipal-form-control"
                  v-model="parametrosConvenio.num_convenio"
                  placeholder="Se genera automáticamente"
                  disabled
                />
              </div>
            </div>
            <div class="col-md-6">
              <div class="form-group">
                <label class="municipal-form-label">Autorizado Por</label>
                <input
                  type="text"
                  class="municipal-form-control"
                  v-model="parametrosConvenio.autorizado_por"
                  placeholder="Nombre del funcionario autorizante"
                />
              </div>
            </div>
          </div>

          <div class="form-group">
            <label class="municipal-form-label">Observaciones</label>
            <textarea
              class="municipal-form-control"
              v-model="parametrosConvenio.observaciones"
              rows="3"
              placeholder="Observaciones o condiciones especiales del convenio..."
            ></textarea>
          </div>

          <div class="form-check mb-3">
            <input
              class="form-check-input"
              type="checkbox"
              v-model="parametrosConvenio.requiere_garantia"
              id="requiereGarantia"
            />
            <label class="form-check-label" for="requiereGarantia">
              Requiere garantía o aval
            </label>
          </div>

          <div class="d-flex gap-2">
            <button class="btn-municipal-secondary" @click="paso = 1">
              <font-awesome-icon icon="arrow-left" class="me-1" />
              Regresar
            </button>
            <button class="btn-municipal-primary" @click="paso = 3" :disabled="!validarConvenio">
              <font-awesome-icon icon="arrow-right" class="me-1" />
              Vista Previa
            </button>
          </div>
        </div>
      </div>

      <!-- Paso 3: Vista Previa -->
      <div v-if="paso === 3" class="municipal-card">
        <div class="municipal-card-header">
        <h5>Paso 3: Vista Previa del Convenio</h5>
        </div>
        <div class="municipal-card-body">
          <!-- Resumen del Convenio -->
          <div class="row">
            <div class="col-md-6">
              <div class="municipal-card mb-3">
                <div class="municipal-card-header">
                  <strong>Datos del Contribuyente</strong>
                </div>
                <div class="municipal-card-body">
                  <p><strong>Contrato:</strong> {{ contratoSeleccionado.num_contrato }}</p>
                  <p><strong>Contribuyente:</strong> {{ contratoSeleccionado.contribuyente }}</p>
                  <p><strong>RFC:</strong> {{ contratoSeleccionado.rfc || 'N/A' }}</p>
                  <p class="mb-0"><strong>Domicilio:</strong> {{ contratoSeleccionado.domicilio }}</p>
                </div>
              </div>
            </div>
            <div class="col-md-6">
              <div class="municipal-card mb-3">
                <div class="municipal-card-header">
                  <strong>Datos del Convenio</strong>
                </div>
                <div class="municipal-card-body">
                  <p><strong>Tipo:</strong> {{ formatTipoConvenio(parametrosConvenio.tipo_convenio) }}</p>
                  <p><strong>Fecha:</strong> {{ formatFecha(parametrosConvenio.fecha_convenio) }}</p>
                  <p><strong>Autorizado Por:</strong> {{ parametrosConvenio.autorizado_por || 'N/A' }}</p>
                  <p class="mb-0"><strong>Requiere Garantía:</strong> {{ parametrosConvenio.requiere_garantia ? 'Sí' : 'No' }}</p>
                </div>
              </div>
            </div>
          </div>

          <!-- Detalle Financiero -->
          <div class="municipal-card mb-3">
            <div class="municipal-card-header">
              <strong>Detalle Financiero</strong>
            </div>
            <div class="municipal-card-body">
              <div class="row">
                <div class="col-md-3">
                  <p><strong>Monto Original:</strong></p>
                  <p class="fs-5">${{ formatCurrency(totalSeleccionado) }}</p>
                </div>
                <div class="col-md-3" v-if="totalCondonacion > 0">
                  <p><strong>Condonación:</strong></p>
                  <p class="fs-5 text-success">- ${{ formatCurrency(totalCondonacion) }}</p>
                </div>
                <div class="col-md-3">
                  <p><strong>Monto a Pagar:</strong></p>
                  <p class="fs-4 text-primary">${{ formatCurrency(montoAPagar) }}</p>
                </div>
                <div class="col-md-3" v-if="parametrosConvenio.num_parcialidades > 0">
                  <p><strong>Parcialidad:</strong></p>
                  <p class="fs-4 text-danger">${{ formatCurrency(montoParcialidad) }}</p>
                </div>
              </div>
            </div>
          </div>

          <!-- Calendario de Pagos -->
          <div v-if="parametrosConvenio.generar_calendario && calendarioPagos.length > 0" class="municipal-card mb-3">
            <div class="municipal-card-header">
              <strong>Calendario de Pagos ({{ parametrosConvenio.num_parcialidades }} parcialidades)</strong>
            </div>
            <div class="municipal-card-body">
              <div class="table-responsive">
                <table class="municipal-table">
                  <thead class="municipal-table-header">
                    <tr>
                      <th>No.</th>
                      <th>Fecha Vencimiento</th>
                      <th class="text-end">Monto</th>
                      <th>Status</th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr v-for="pago in calendarioPagos" :key="pago.numero">
                      <td>{{ pago.numero }}</td>
                      <td>{{ formatFecha(pago.fecha_vencimiento) }}</td>
                      <td class="text-end">${{ formatCurrency(pago.monto) }}</td>
                      <td>
                        <span class="badge badge-warning">Pendiente</span>
                      </td>
                    </tr>
                  </tbody>
                </table>
              </div>
            </div>
          </div>

          <!-- Adeudos Incluidos -->
          <div class="municipal-card mb-3">
            <div class="municipal-card-header">
              <strong>Adeudos Incluidos ({{ adeudosSeleccionados.length }})</strong>
            </div>
            <div class="municipal-card-body">
              <div class="table-responsive">
                <table class="municipal-table">
                  <thead class="municipal-table-header">
                    <tr>
                      <th>Folio</th>
                      <th>Periodo</th>
                      <th class="text-end">Cuota Base</th>
                      <th class="text-end">Recargos</th>
                      <th class="text-end">Gastos</th>
                      <th class="text-end">Total</th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr v-for="adeudo in adeudosIncluidos" :key="adeudo.folio">
                      <td>{{ adeudo.folio }}</td>
                      <td>{{ adeudo.periodo }}</td>
                      <td class="text-end">${{ formatCurrency(adeudo.cuota_base) }}</td>
                      <td class="text-end">${{ formatCurrency(adeudo.recargos) }}</td>
                      <td class="text-end">${{ formatCurrency(adeudo.gastos_cobranza) }}</td>
                      <td class="text-end">${{ formatCurrency(adeudo.total_periodo) }}</td>
                    </tr>
                  </tbody>
                </table>
              </div>
            </div>
          </div>

          <div class="d-flex gap-2">
            <button class="btn-municipal-secondary" @click="paso = 2">
              <font-awesome-icon icon="arrow-left" class="me-1" />
              Regresar
            </button>
            <button class="btn-municipal-primary" @click="confirmarCreacion" :disabled="creando">
              <font-awesome-icon icon="check" class="me-1" />
              <span v-if="!creando">Crear Convenio</span>
              <span v-else>
                <span class="spinner-border spinner-border-sm me-1"></span>
                Creando...
              </span>
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Tab: Consulta de Convenios -->
    <div v-if="tabActual === 'consulta'">
      <div class="municipal-card">
        <div class="municipal-card-header">
        <h5>Consulta de Convenios</h5>
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
                <label class="municipal-form-label">Tipo</label>
                <select class="municipal-form-control" v-model="filtrosConsulta.tipo">
                  <option value="">Todos</option>
                  <option value="PARCIALIDADES">Parcialidades</option>
                  <option value="QUITA">Quita</option>
                  <option value="MIXTO">Mixto</option>
                </select>
              </div>
            </div>
            <div class="col-md-3">
              <div class="form-group">
                <label class="municipal-form-label">Status</label>
                <select class="municipal-form-control" v-model="filtrosConsulta.status">
                  <option value="">Todos</option>
                  <option value="VIGENTE">Vigente</option>
                  <option value="CUMPLIDO">Cumplido</option>
                  <option value="INCUMPLIDO">Incumplido</option>
                  <option value="CANCELADO">Cancelado</option>
                </select>
              </div>
            </div>
          </div>

          <div class="row mb-3">
            <div class="col-md-9">
              <div class="form-group">
                <label class="municipal-form-label">Buscar</label>
                <input
                  type="text"
                  class="municipal-form-control"
                  v-model="filtrosConsulta.busqueda"
                  placeholder="Buscar por número de convenio, contrato, contribuyente..."
                />
              </div>
            </div>
            <div class="col-md-3">
              <label class="municipal-form-label">&nbsp;</label>
              <button class="btn-municipal-primary w-100" @click="consultarConvenios" :disabled="cargando">
                <font-awesome-icon icon="search" class="me-1" />
                Consultar
              </button>
            </div>
          </div>

          <!-- Resultados -->
          <div v-if="conveniosEncontrados.length > 0">
            <div class="table-responsive">
              <table class="municipal-table">
                <thead class="municipal-table-header">
                  <tr>
                    <th>Convenio</th>
                    <th>Fecha</th>
                    <th>Contrato</th>
                    <th>Contribuyente</th>
                    <th>Tipo</th>
                    <th class="text-end">Monto</th>
                    <th>Parcialidades</th>
                    <th>Status</th>
                    <th>Acciones</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="convenio in conveniosFiltrados" :key="convenio.num_convenio">
                    <td>{{ convenio.num_convenio }}</td>
                    <td>{{ formatFecha(convenio.fecha_convenio) }}</td>
                    <td>{{ convenio.num_contrato }}</td>
                    <td>{{ convenio.contribuyente }}</td>
                    <td>{{ formatTipoConvenio(convenio.tipo_convenio) }}</td>
                    <td class="text-end">${{ formatCurrency(convenio.monto_convenio) }}</td>
                    <td>{{ convenio.parcialidades_pagadas || 0 }} / {{ convenio.num_parcialidades || 0 }}</td>
                    <td>
                      <span class="municipal-badge" :class="{
                        'municipal-badge-success': convenio.status === 'VIGENTE',
                        'municipal-badge-primary': convenio.status === 'CUMPLIDO',
                        'municipal-badge-danger': convenio.status === 'INCUMPLIDO',
                        'municipal-badge-secondary': convenio.status === 'CANCELADO'
                      }">
                        {{ convenio.status }}
                      </span>
                    </td>
                    <td>
                      <button
                        class="btn-municipal-info btn-sm me-1"
                        @click="verDetalleConvenio(convenio)"
                        title="Ver detalle"
                      >
                        <font-awesome-icon icon="eye" />
                      </button>
                      <button
                        class="btn-municipal-primary btn-sm me-1"
                        @click="verParcialidades(convenio)"
                        v-if="convenio.num_parcialidades > 0"
                        title="Ver parcialidades"
                      >
                        <font-awesome-icon icon="calendar-check" />
                      </button>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>

            <!-- Resumen -->
            <div class="alert alert-info mt-3">
              <div class="row">
                <div class="col-md-3">
                  <strong>Total Convenios:</strong> {{ conveniosEncontrados.length }}
                </div>
                <div class="col-md-3">
                  <strong>Vigentes:</strong> {{ conveniosVigentes }}
                </div>
                <div class="col-md-3">
                  <strong>Cumplidos:</strong> {{ conveniosCumplidos }}
                </div>
                <div class="col-md-3">
                  <strong>Monto Total:</strong> ${{ formatCurrency(montoTotalConvenios) }}
                </div>
              </div>
            </div>
          </div>

          <div v-else-if="!cargando" class="municipal-alert municipal-alert-warning">
            <font-awesome-icon icon="info-circle" class="me-2" />
            No se encontraron convenios con los criterios especificados.
          </div>
        </div>
      </div>
    </div>

    <!-- Tab: Parcialidades -->
    <div v-if="tabActual === 'parcialidades'">
      <div class="municipal-card">
        <div class="municipal-card-header">
        <h5>Seguimiento de Parcialidades</h5>
        </div>
        <div class="municipal-card-body">
          <p class="text-muted">Seleccione un convenio desde la pestaña de consulta para ver sus parcialidades.</p>
        </div>
      </div>
    </div>
    </div>

    <!-- Modal de Ayuda -->

    <DocumentationModal
      v-if="mostrarAyuda"
      :show="mostrarAyuda"
      @close="mostrarAyuda = false"
      title="Gestión de Convenios - Ayuda"
    >
      <h6>Descripción</h6>
      <p>
        Este módulo permite registrar y dar seguimiento a convenios de pago para adeudos de aseo contratado,
        facilitando acuerdos de pago con los contribuyentes.
      </p>

      <h6>Tipos de Convenio</h6>
      <ul>
        <li><strong>Parcialidades:</strong> Pago diferido del adeudo en mensualidades</li>
        <li><strong>Quita:</strong> Condonación parcial o total de recargos y gastos</li>
        <li><strong>Mixto:</strong> Combinación de quita y parcialidades</li>
      </ul>

      <h6>Proceso de Creación</h6>
      <ol>
        <li>Buscar contrato y seleccionar adeudos a incluir</li>
        <li>Configurar tipo de convenio, quitas y parcialidades</li>
        <li>Revisar vista previa y calendario de pagos</li>
        <li>Confirmar creación del convenio</li>
      </ol>

      <h6>Consideraciones</h6>
      <ul>
        <li>Los convenios requieren autorización del funcionario competente</li>
        <li>Se puede generar calendario de pagos automático</li>
        <li>Se pueden requerir garantías según el monto</li>
        <li>El incumplimiento puede generar cancelación automática</li>
      </ul>
    </DocumentationModal>
    <!-- Modal de Documentacion Tecnica -->
    <TechnicalDocsModal
      :show="showTechDocs"
      :componentName="'DatosConvenio'"
      :moduleName="'aseo_contratado'"
      @close="closeTechDocs"
    />

  </div>
</template>

<script setup>
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import TechnicalDocsModal from '@/components/common/TechnicalDocsModal.vue'
import { ref, computed, watch } from 'vue'
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome'
import Swal from 'sweetalert2'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useToast } from '@/composables/useToast'

const { execute } = useApi()
const { handleApiError } = useLicenciasErrorHandler()
const { showToast } = useToast()
const { showLoading, hideLoading } = useGlobalLoading()

// Estado
const tabActual = ref('nuevo')
const paso = ref(1)
const cargando = ref(false)
const creando = ref(false)
const mostrarAyuda = ref(false)

// Búsqueda
const busqueda = ref({
  num_contrato: ''
})

// Datos
const contratoSeleccionado = ref(null)
const adeudosDisponibles = ref([])
const adeudosSeleccionados = ref([])
const todosMarcados = ref(false)

// Parámetros del Convenio
const parametrosConvenio = ref({
  tipo_convenio: '',
  fecha_convenio: new Date().toISOString().split('T')[0],
  condonar_recargos: false,
  porcentaje_recargos: 100,
  condonar_gastos: false,
  porcentaje_gastos: 100,
  num_parcialidades: 0,
  fecha_primer_pago: '',
  periodicidad: 'MENSUAL',
  generar_calendario: true,
  num_convenio: '',
  autorizado_por: '',
  observaciones: '',
  requiere_garantia: false
})

// Consulta
const filtrosConsulta = ref({
  fecha_desde: '',
  fecha_hasta: '',
  tipo: '',
  status: '',
  busqueda: ''
})

const conveniosEncontrados = ref([])

// Computed
const fechaActual = computed(() => {
  return new Date().toISOString().split('T')[0]
})

const totalSeleccionado = computed(() => {
  return adeudosDisponibles.value
    .filter(a => adeudosSeleccionados.value.includes(a.folio))
    .reduce((sum, a) => sum + parseFloat(a.total_periodo || 0), 0)
})

const adeudosIncluidos = computed(() => {
  return adeudosDisponibles.value.filter(a => adeudosSeleccionados.value.includes(a.folio))
})

const totalRecargos = computed(() => {
  return adeudosIncluidos.value.reduce((sum, a) => sum + parseFloat(a.recargos || 0), 0)
})

const totalGastos = computed(() => {
  return adeudosIncluidos.value.reduce((sum, a) => sum + parseFloat(a.gastos_cobranza || 0), 0)
})

const porcentajeRecargos = computed(() => parametrosConvenio.value.porcentaje_recargos)
const porcentajeGastos = computed(() => parametrosConvenio.value.porcentaje_gastos)

const montoRecargosCondonar = computed(() => {
  if (!parametrosConvenio.value.condonar_recargos) return 0
  return (totalRecargos.value * parametrosConvenio.value.porcentaje_recargos) / 100
})

const montoGastosCondonar = computed(() => {
  if (!parametrosConvenio.value.condonar_gastos) return 0
  return (totalGastos.value * parametrosConvenio.value.porcentaje_gastos) / 100
})

const totalCondonacion = computed(() => {
  return montoRecargosCondonar.value + montoGastosCondonar.value
})

const montoAPagar = computed(() => {
  return totalSeleccionado.value - totalCondonacion.value
})

const montoParcialidad = computed(() => {
  if (parametrosConvenio.value.num_parcialidades === 0) return 0
  return montoAPagar.value / parametrosConvenio.value.num_parcialidades
})

const fechaUltimoPago = computed(() => {
  if (!parametrosConvenio.value.fecha_primer_pago || parametrosConvenio.value.num_parcialidades === 0) return 'N/A'

  const fecha = new Date(parametrosConvenio.value.fecha_primer_pago)
  const meses = parametrosConvenio.value.num_parcialidades
  fecha.setMonth(fecha.getMonth() + meses - 1)

  return formatFecha(fecha.toISOString().split('T')[0])
})

const calendarioPagos = computed(() => {
  if (!parametrosConvenio.value.generar_calendario ||
      !parametrosConvenio.value.fecha_primer_pago ||
      parametrosConvenio.value.num_parcialidades === 0) {
    return []
  }

  const calendario = []
  const fechaInicio = new Date(parametrosConvenio.value.fecha_primer_pago)

  for (let i = 0; i < parametrosConvenio.value.num_parcialidades; i++) {
    const fecha = new Date(fechaInicio)
    fecha.setMonth(fecha.getMonth() + i)

    calendario.push({
      numero: i + 1,
      fecha_vencimiento: fecha.toISOString().split('T')[0],
      monto: montoParcialidad.value
    })
  }

  return calendario
})

const validarConvenio = computed(() => {
  if (!parametrosConvenio.value.tipo_convenio) return false
  if (!parametrosConvenio.value.fecha_convenio) return false

  if (parametrosConvenio.value.tipo_convenio === 'PARCIALIDADES' ||
      parametrosConvenio.value.tipo_convenio === 'MIXTO') {
    if (parametrosConvenio.value.num_parcialidades === 0) return false
    if (!parametrosConvenio.value.fecha_primer_pago) return false
  }

  return true
})

const conveniosFiltrados = computed(() => {
  let resultado = [...conveniosEncontrados.value]

  if (filtrosConsulta.value.busqueda) {
    const busq = filtrosConsulta.value.busqueda.toLowerCase()
    resultado = resultado.filter(c =>
      c.num_convenio.toLowerCase().includes(busq) ||
      c.num_contrato.toLowerCase().includes(busq) ||
      c.contribuyente.toLowerCase().includes(busq)
    )
  }

  return resultado
})

const conveniosVigentes = computed(() => {
  return conveniosEncontrados.value.filter(c => c.status === 'VIGENTE').length
})

const conveniosCumplidos = computed(() => {
  return conveniosEncontrados.value.filter(c => c.status === 'CUMPLIDO').length
})

const montoTotalConvenios = computed(() => {
  return conveniosEncontrados.value.reduce((sum, c) => sum + parseFloat(c.monto_convenio || 0), 0)
})

// Watchers
watch(() => parametrosConvenio.value.tipo_convenio, (newVal) => {
  if (newVal === 'QUITA') {
    parametrosConvenio.value.num_parcialidades = 0
  }
})

// Métodos
const cambiarTab = (tab) => {
  tabActual.value = tab
  if (tab === 'nuevo') {
    paso.value = 1
  }
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

      // Cargar adeudos
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
    hideLoading()
    handleApiError(error, 'Error al buscar contrato')
    contratoSeleccionado.value = null
    adeudosDisponibles.value = []
  } finally {
    cargando.value = false
  }
}

const confirmarCreacion = async () => {
  const result = await Swal.fire({
    title: '¿Confirmar Creación de Convenio?',
    html: `
      <p>Tipo: <strong>${formatTipoConvenio(parametrosConvenio.value.tipo_convenio)}</strong></p>
      <p>Monto a Pagar: <strong>$${formatCurrency(montoAPagar.value)}</strong></p>
      ${parametrosConvenio.value.num_parcialidades > 0 ?
        `<p>Parcialidades: <strong>${parametrosConvenio.value.num_parcialidades} de $${formatCurrency(montoParcialidad.value)}</strong></p>` : ''}
      ${totalCondonacion.value > 0 ?
        `<p>Condonación: <strong>$${formatCurrency(totalCondonacion.value)}</strong></p>` : ''}
    `,
    icon: 'question',
    showCancelButton: true,
    confirmButtonColor: '#28a745',
    confirmButtonText: 'Sí, Crear',
    cancelButtonText: 'Cancelar'
  })

  if (result.isConfirmed) {
    await crearConvenio()
  }
}

const crearConvenio = async () => {
  creando.value = true
  try {
    const response = await execute('SP_ASEO_CONVENIO_CREAR', 'aseo_contratado', {
      p_control_contrato: contratoSeleccionado.value.control_contrato,
      p_tipo_convenio: parametrosConvenio.value.tipo_convenio,
      p_fecha_convenio: parametrosConvenio.value.fecha_convenio,
      p_adeudos: adeudosSeleccionados.value.join(','),
      p_monto_original: totalSeleccionado.value,
      p_monto_condonacion: totalCondonacion.value,
      p_monto_pagar: montoAPagar.value,
      p_num_parcialidades: parametrosConvenio.value.num_parcialidades,
      p_fecha_primer_pago: parametrosConvenio.value.fecha_primer_pago,
      p_periodicidad: parametrosConvenio.value.periodicidad,
      p_autorizado_por: parametrosConvenio.value.autorizado_por,
      p_observaciones: parametrosConvenio.value.observaciones,
      p_requiere_garantia: parametrosConvenio.value.requiere_garantia ? 'S' : 'N',
      p_calendario: parametrosConvenio.value.generar_calendario ? JSON.stringify(calendarioPagos.value) : null
    })

    await Swal.fire({
      title: 'Convenio Creado',
      html: `El convenio <strong>${response[0].num_convenio}</strong> ha sido creado exitosamente`,
      icon: 'success',
      confirmButtonColor: '#28a745'
    })

    // Reiniciar
    contratoSeleccionado.value = null
    adeudosDisponibles.value = []
    adeudosSeleccionados.value = []
    parametrosConvenio.value = {
      tipo_convenio: '',
      fecha_convenio: new Date().toISOString().split('T')[0],
      condonar_recargos: false,
      porcentaje_recargos: 100,
      condonar_gastos: false,
      porcentaje_gastos: 100,
      num_parcialidades: 0,
      fecha_primer_pago: '',
      periodicidad: 'MENSUAL',
      generar_calendario: true,
      num_convenio: '',
      autorizado_por: '',
      observaciones: '',
      requiere_garantia: false
    }
    busqueda.value.num_contrato = ''
    paso.value = 1

  } catch (error) {
    hideLoading()
    handleApiError(error, 'Error al crear convenio')
  } finally {
    creando.value = false
  }
}

const consultarConvenios = async () => {
  cargando.value = true
  try {
    const response = await execute('SP_ASEO_CONVENIOS_CONSULTAR', 'aseo_contratado', {
      p_fecha_desde: filtrosConsulta.value.fecha_desde || null,
      p_fecha_hasta: filtrosConsulta.value.fecha_hasta || null,
      p_tipo: filtrosConsulta.value.tipo || null,
      p_status: filtrosConsulta.value.status || null
    })

    conveniosEncontrados.value = response || []
    showToast(`${conveniosEncontrados.value.length} convenio(s) encontrado(s)`, 'success')
  } catch (error) {
    hideLoading()
    handleApiError(error, 'Error al consultar convenios')
    conveniosEncontrados.value = []
  } finally {
    cargando.value = false
  }
}

const verDetalleConvenio = async (convenio) => {
  await Swal.fire({
    title: `Convenio ${convenio.num_convenio}`,
    html: `
      <div class="text-start">
        <p><strong>Tipo:</strong> ${formatTipoConvenio(convenio.tipo_convenio)}</p>
        <p><strong>Fecha:</strong> ${formatFecha(convenio.fecha_convenio)}</p>
        <p><strong>Contrato:</strong> ${convenio.num_contrato}</p>
        <p><strong>Contribuyente:</strong> ${convenio.contribuyente}</p>
        <p><strong>Monto Original:</strong> $${formatCurrency(convenio.monto_original)}</p>
        ${convenio.monto_condonacion > 0 ? `<p><strong>Condonación:</strong> $${formatCurrency(convenio.monto_condonacion)}</p>` : ''}
        <p><strong>Monto a Pagar:</strong> $${formatCurrency(convenio.monto_convenio)}</p>
        ${convenio.num_parcialidades > 0 ? `<p><strong>Parcialidades:</strong> ${convenio.parcialidades_pagadas} / ${convenio.num_parcialidades}</p>` : ''}
        ${convenio.observaciones ? `<p><strong>Observaciones:</strong> ${convenio.observaciones}</p>` : ''}
      </div>
    `,
    icon: 'info',
    width: '600px',
    confirmButtonText: 'Cerrar'
  })
}

const verParcialidades = (convenio) => {
  tabActual.value = 'parcialidades'
  // Aquí se cargarían las parcialidades del convenio
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

const formatTipoConvenio = (tipo) => {
  const tipos = {
    'PARCIALIDADES': 'Pago en Parcialidades',
    'QUITA': 'Quita de Recargos/Gastos',
    'MIXTO': 'Mixto (Quita + Parcialidades)'
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

// Documentacion y Ayuda
const showDocumentation = ref(false)
const openDocumentation = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false
const showTechDocs = ref(false)
const mostrarDocumentacion = () => showTechDocs.value = true
const closeTechDocs = () => showTechDocs.value = false

</script>

