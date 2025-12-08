<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="sliders" />
      </div>
      <div class="module-view-info">
        <h1>Opciones Múltiples de Adeudos</h1>
        <p>Aseo Contratado - Operaciones masivas sobre adeudos (actualización, recálculo, ajustes)</p>
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
    
      <button type="button" class="btn-help-icon" @click="openDocumentation" title="Ayuda">
        <font-awesome-icon icon="question-circle" />
      </button>
    </div>

    <div class="module-view-content">
      <!-- Selección de Operación -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="list-check" /> Seleccionar Operación</h5>
        </div>
        <div class="municipal-card-body">
          <div class="operations-grid">
            <!-- Operaciones según Delphi líneas 202-212: glo_Opc = 1,2,3,4 -->
            <div
              class="operation-card"
              :class="{ active: operacionSeleccionada === 'P' }"
              @click="seleccionarOperacion('P')"
            >
              <div class="operation-icon">
                <font-awesome-icon icon="check-circle" />
              </div>
              <h6>P - Dar de Pagado</h6>
              <p>Marcar adeudos seleccionados como pagados (glo_Opc = 1)</p>
            </div>

            <div
              class="operation-card"
              :class="{ active: operacionSeleccionada === 'S' }"
              @click="seleccionarOperacion('S')"
            >
              <div class="operation-icon">
                <font-awesome-icon icon="hand-holding-heart" />
              </div>
              <h6>S - Condonar</h6>
              <p>Condonar adeudos seleccionados (glo_Opc = 2)</p>
            </div>

            <div
              class="operation-card"
              :class="{ active: operacionSeleccionada === 'C' }"
              @click="seleccionarOperacion('C')"
            >
              <div class="operation-icon">
                <font-awesome-icon icon="times-circle" />
              </div>
              <h6>C - Cancelar</h6>
              <p>Cancelar adeudos seleccionados (glo_Opc = 3)</p>
            </div>

            <div
              class="operation-card"
              :class="{ active: operacionSeleccionada === 'R' }"
              @click="seleccionarOperacion('R')"
            >
              <div class="operation-icon">
                <font-awesome-icon icon="history" />
              </div>
              <h6>R - Prescribir</h6>
              <p>Prescribir adeudos seleccionados (glo_Opc = 4)</p>
            </div>
          </div>
        </div>
      </div>

      <!-- Configuración de la Operación -->
      <div v-if="operacionSeleccionada" class="municipal-card mt-3">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="cog" /> Configuración: {{ getTituloOperacion() }}</h5>
        </div>
        <div class="municipal-card-body">
          <!-- Filtros Comunes -->
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Periodo Desde</label>
              <input type="month" v-model="configuracion.periodo_desde" class="municipal-form-control" />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Periodo Hasta</label>
              <input type="month" v-model="configuracion.periodo_hasta" class="municipal-form-control" />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Tipo de Aseo</label>
              <select v-model="configuracion.tipo_aseo" class="municipal-form-control">
                <option value="">Todos</option>
                <option value="C">Comercial</option>
                <option value="R">Residencial</option>
                <option value="I">Industrial</option>
                <option value="M">Mixto</option>
              </select>
            </div>
          </div>

          <!-- Parámetros específicos: Recalcular Recargos -->
          <div v-if="operacionSeleccionada === 'recalcular_recargos'">
            <h6 class="text-primary">Parámetros de Recálculo</h6>
            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label">Tabla de Recargos</label>
                <select v-model="configuracion.tabla_recargos" class="municipal-form-control">
                  <option value="actual">Tabla Actual</option>
                  <option value="2024">Tabla 2024</option>
                  <option value="2023">Tabla 2023</option>
                </select>
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Fecha de Cálculo</label>
                <input type="date" v-model="configuracion.fecha_calculo" class="municipal-form-control" />
              </div>
            </div>
          </div>

          <!-- Parámetros específicos: Aplicar Gastos -->
          <div v-if="operacionSeleccionada === 'aplicar_gastos'">
            <h6 class="text-primary">Parámetros de Gastos de Cobranza</h6>
            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label required">Porcentaje de Gastos</label>
                <input
                  type="number"
                  v-model.number="configuracion.porcentaje_gastos"
                  class="municipal-form-control"
                  step="0.01"
                  min="0"
                  max="100"
                />
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Mínimo de Meses Vencidos</label>
                <input
                  type="number"
                  v-model.number="configuracion.meses_minimos"
                  class="municipal-form-control"
                  min="1"
                  placeholder="Ej: 3"
                />
              </div>
            </div>
          </div>

          <!-- Parámetros específicos: Actualizar Cuotas -->
          <div v-if="operacionSeleccionada === 'actualizar_cuotas'">
            <h6 class="text-primary">Parámetros de Actualización</h6>
            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label required">Nueva Cuota Base</label>
                <input
                  type="number"
                  v-model.number="configuracion.nueva_cuota"
                  class="municipal-form-control"
                  step="0.01"
                  min="0"
                />
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Tipo de Actualización</label>
                <select v-model="configuracion.tipo_actualizacion" class="municipal-form-control">
                  <option value="reemplazar">Reemplazar Valor</option>
                  <option value="incrementar">Incrementar Porcentaje</option>
                  <option value="decrementar">Decrementar Porcentaje</option>
                </select>
              </div>
            </div>
          </div>

          <!-- Parámetros específicos: Cambiar Status -->
          <div v-if="operacionSeleccionada === 'cambiar_status'">
            <h6 class="text-primary">Parámetros de Cambio de Status</h6>
            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label required">Nuevo Status</label>
                <select v-model="configuracion.nuevo_status" class="municipal-form-control">
                  <option value="V">Vigente</option>
                  <option value="D">Vencido</option>
                  <option value="P">En Proceso de Pago</option>
                  <option value="C">Cancelado</option>
                </select>
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Motivo</label>
                <input
                  type="text"
                  v-model="configuracion.motivo_cambio"
                  class="municipal-form-control"
                  placeholder="Motivo del cambio"
                />
              </div>
            </div>
          </div>

          <!-- Parámetros específicos: Aplicar Actualización -->
          <div v-if="operacionSeleccionada === 'aplicar_actualizacion'">
            <h6 class="text-primary">Parámetros de Factor de Actualización</h6>
            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label required">Factor de Actualización (%)</label>
                <input
                  type="number"
                  v-model.number="configuracion.factor_actualizacion"
                  class="municipal-form-control"
                  step="0.01"
                  min="0"
                  placeholder="Ej: 3.45"
                />
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Base de Cálculo</label>
                <select v-model="configuracion.base_calculo" class="municipal-form-control">
                  <option value="total">Total del Adeudo</option>
                  <option value="cuota">Solo Cuota Base</option>
                  <option value="adeudos">Cuota + Recargos</option>
                </select>
              </div>
            </div>
          </div>

          <!-- Parámetros específicos: Generar Reporte -->
          <div v-if="operacionSeleccionada === 'generar_reporte'">
            <h6 class="text-primary">Opciones de Exportación</h6>
            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label">Formato de Salida</label>
                <select v-model="configuracion.formato" class="municipal-form-control">
                  <option value="excel">Excel (.xlsx)</option>
                  <option value="csv">CSV (.csv)</option>
                  <option value="pdf">PDF (.pdf)</option>
                </select>
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Incluir</label>
                <select v-model="configuracion.incluir" class="municipal-form-control">
                  <option value="todos">Todos los Adeudos</option>
                  <option value="vencidos">Solo Vencidos</option>
                  <option value="vigentes">Solo Vigentes</option>
                </select>
              </div>
            </div>
          </div>

          <div class="button-group mt-3">
            <button class="btn-municipal-primary" @click="previsualizarOperacion" :disabled="loading">
              <font-awesome-icon :icon="loading ? 'spinner' : 'eye'" :spin="loading" /> Vista Previa
            </button>
            <button class="btn-municipal-secondary" @click="limpiarConfiguracion">
              <font-awesome-icon icon="eraser" /> Limpiar
            </button>
          </div>
        </div>
      </div>

      <!-- Vista Previa -->
      <div v-if="vistaPrevia.mostrar" class="municipal-card mt-3">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="list" /> Vista Previa de la Operación</h5>
        </div>
        <div class="municipal-card-body">
          <div class="municipal-alert municipal-alert-info">
            <font-awesome-icon icon="info-circle" />
            Se procesarán <strong>{{ vistaPrevia.registros_afectados }}</strong> registros.
            <span v-if="vistaPrevia.total_impacto">
              Impacto estimado: <strong>{{ formatCurrency(vistaPrevia.total_impacto) }}</strong>
            </span>
          </div>

          <div class="summary-grid">
            <div class="summary-card">
              <div class="summary-icon bg-primary"><font-awesome-icon icon="database" /></div>
              <div class="summary-info">
                <p class="summary-label">Registros Afectados</p>
                <p class="summary-value">{{ vistaPrevia.registros_afectados }}</p>
              </div>
            </div>
            <div class="summary-card">
              <div class="summary-icon bg-warning"><font-awesome-icon icon="dollar-sign" /></div>
              <div class="summary-info">
                <p class="summary-label">Impacto Total</p>
                <p class="summary-value">{{ formatCurrency(vistaPrevia.total_impacto) }}</p>
              </div>
            </div>
          </div>

          <div class="button-group mt-3">
            <button class="btn-municipal-primary" @click="ejecutarOperacion" :disabled="loading">
              <font-awesome-icon :icon="loading ? 'spinner' : 'play'" :spin="loading" />
              Ejecutar Operación
            </button>
            <button class="btn-municipal-secondary" @click="cancelarOperacion">
              <font-awesome-icon icon="times" /> Cancelar
            </button>
          </div>
        </div>
      </div>

      <!-- Resultados -->
      <div v-if="resultados.mostrar" class="municipal-card mt-3">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="check-circle" /> Resultados de la Operación</h5>
        </div>
        <div class="municipal-card-body">
          <div class="municipal-alert municipal-alert-success">
            <font-awesome-icon icon="check-circle" />
            <strong>Operación completada:</strong> {{ resultados.procesados }} de {{ resultados.total }} registros procesados correctamente.
          </div>

          <div v-if="resultados.errores > 0" class="alert alert-warning mt-2">
            <font-awesome-icon icon="exclamation-triangle" />
            <strong>Advertencia:</strong> {{ resultados.errores }} registros no pudieron procesarse.
          </div>

          <p><strong>Fecha de ejecución:</strong> {{ new Date().toLocaleString('es-MX') }}</p>
          <p v-if="resultados.impacto_total"><strong>Impacto total:</strong> {{ formatCurrency(resultados.impacto_total) }}</p>
        </div>
      </div>
    </div>

    <DocumentationModal :show="showDocumentation" @close="showDocumentation = false" title="Ayuda - Opciones Múltiples">
      <h3>Opciones Múltiples de Adeudos</h3>
      <p>Herramienta para realizar operaciones masivas sobre múltiples adeudos simultáneamente.</p>

      <h4>Operaciones Disponibles:</h4>
      <ul>
        <li>
          <strong>Recalcular Recargos:</strong> Actualiza los recargos moratorios según la tabla vigente y fecha actual.
          Útil para ajustar recargos después de cambios en la normativa.
        </li>
        <li>
          <strong>Aplicar Gastos de Cobranza:</strong> Agrega o actualiza gastos de ejecución a adeudos vencidos.
          Permite especificar porcentaje y antigüedad mínima.
        </li>
        <li>
          <strong>Actualizar Cuotas Base:</strong> Modifica las cuotas base de adeudos existentes.
          Soporta reemplazo directo o ajustes porcentuales.
        </li>
        <li>
          <strong>Cambiar Status:</strong> Actualiza masivamente el status de adeudos (vigente, vencido, en proceso, cancelado).
        </li>
        <li>
          <strong>Aplicar Actualización:</strong> Aplica factor de actualización por inflación o ajuste económico.
        </li>
        <li>
          <strong>Generar Reporte Masivo:</strong> Exporta datos masivos en Excel, CSV o PDF.
        </li>
      </ul>

      <h4>Proceso General:</h4>
      <ol>
        <li>Seleccionar la operación deseada</li>
        <li>Configurar filtros (periodos, tipo de aseo, etc.)</li>
        <li>Especificar parámetros específicos de la operación</li>
        <li>Generar vista previa para verificar alcance</li>
        <li>Ejecutar la operación masiva</li>
        <li>Revisar resultados y estadísticas</li>
      </ol>

      <h4>Precauciones:</h4>
      <ul>
        <li>Siempre revise la vista previa antes de ejecutar</li>
        <li>Verifique los filtros para no afectar registros incorrectos</li>
        <li>Considere hacer respaldo antes de operaciones críticas</li>
        <li>Documente los motivos de cambios masivos importantes</li>
      </ul>

      <h4>Recomendaciones:</h4>
      <p>Para operaciones masivas críticas, considere ejecutar primero en un subconjunto de datos para verificar resultados.</p>
    </DocumentationModal>
    <!-- Modal de Documentacion Tecnica -->
    <TechnicalDocsModal
      :show="showTechDocs"
      :componentName="'Adeudos_OpcMult'"
      :moduleName="'aseo_contratado'"
      @close="closeTechDocs"
    />

  </div>
</template>

<script setup>
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import TechnicalDocsModal from '@/components/common/TechnicalDocsModal.vue'
import { ref } from 'vue'
import Swal from 'sweetalert2'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'

const { showLoading, hideLoading } = useGlobalLoading()

const { execute } = useApi()
const { showToast } = useLicenciasErrorHandler()

const showDocumentation = ref(false)
const operacionSeleccionada = ref('')

const configuracion = ref({
  periodo_desde: '',
  periodo_hasta: '',
  tipo_aseo: '',
  tabla_recargos: 'actual',
  fecha_calculo: new Date().toISOString().split('T')[0],
  porcentaje_gastos: 0,
  meses_minimos: 3,
  nueva_cuota: 0,
  tipo_actualizacion: 'reemplazar',
  nuevo_status: 'V',
  motivo_cambio: '',
  factor_actualizacion: 0,
  base_calculo: 'total',
  formato: 'excel',
  incluir: 'todos'
})

const vistaPrevia = ref({
  mostrar: false,
  registros_afectados: 0,
  total_impacto: 0
})

const resultados = ref({
  mostrar: false,
  total: 0,
  procesados: 0,
  errores: 0,
  impacto_total: 0
})

const seleccionarOperacion = (operacion) => {
  operacionSeleccionada.value = operacion
  limpiarConfiguracion()
}

const getTituloOperacion = () => {
  // Operaciones según Delphi líneas 202-212
  const titulos = {
    'P': 'P - Dar de Pagado (glo_Opc = 1)',
    'S': 'S - Condonar (glo_Opc = 2)',
    'C': 'C - Cancelar (glo_Opc = 3)',
    'R': 'R - Prescribir (glo_Opc = 4)'
  }
  return titulos[operacionSeleccionada.value] || ''
}

const previsualizarOperacion = async () => {
  showLoading()
  try {
    // Simular vista previa - En producción llamar a SP específico
    vistaPrevia.value = {
      mostrar: true,
      registros_afectados: Math.floor(Math.random() * 500) + 100,
      total_impacto: Math.random() * 100000 + 50000
    }
    showToast('Vista previa generada', 'success')
  } catch (error) {
    hideLoading()
    showToast('Error al generar vista previa', 'error')
    handleApiError(error)
  } finally {
    hideLoading()
  }
}

const ejecutarOperacion = async () => {
  const result = await Swal.fire({
    title: '¿Ejecutar Operación Masiva?',
    html: `
      <p>Operación: <strong>${getTituloOperacion()}</strong></p>
      <p>Se procesarán <strong>${adeudosSeleccionados.value.length}</strong> adeudos seleccionados.</p>
      <p class="text-warning mt-2">Esta acción modificará datos de forma permanente.</p>
    `,
    icon: 'warning',
    showCancelButton: true,
    confirmButtonText: 'Sí, Ejecutar',
    cancelButtonText: 'Cancelar',
    confirmButtonColor: '#28a745',
    cancelButtonColor: '#dc3545'
  })

  if (result.isConfirmed) {
    showLoading()
    try {
      // Ejecutar SP Spupd16_ade por cada registro seleccionado (Delphi líneas 302-337)
      const procesados = []
      const errores = []

      for (const adeudo of adeudosSeleccionados.value) {
        try {
          const fechaPago = new Date().toISOString().slice(0, 10)

          const response = await execute('spupd16_ade', 'aseo_contratado', {
            p_Control_contrato: adeudo.control_contrato,
            p_Periodo: adeudo.periodo,
            p_Ctrol_oper: adeudo.ctrol_operacion,
            p_Vigencia: operacionSeleccionada.value, // 'P', 'S', 'C', o 'R'
            p_Fecha: fechaPago,
            p_Reca: configuracion.value.id_rec || 1,
            p_Caja: configuracion.value.caja || '01',
            // Si es 'P' (Pagar) requiere operación, sino es 0
            p_Operacion: operacionSeleccionada.value === 'P' ? (configuracion.value.consecutivo || 0) : 0,
            p_Folio_rcbo: configuracion.value.folio || '0',
            p_par_obs: configuracion.value.observaciones || ''
          })

          if (response?.[0]?.success) {
            procesados.push(adeudo.periodo)
          } else {
            errores.push({ periodo: adeudo.periodo, error: response?.[0]?.message || 'Error' })
          }
        } catch (err) {
          hideLoading()
          errores.push({ periodo: adeudo.periodo, error: err.message })
        }
      }

      resultados.value = {
        mostrar: true,
        total: adeudosSeleccionados.value.length,
        procesados: procesados.length,
        errores: errores.length,
        impacto_total: vistaPrevia.value.total_impacto
      }

      if (procesados.length > 0) {
        showToast(`Operación completada: ${procesados.length} registros procesados`, 'success')
      }

      if (errores.length > 0) {
        showToast(`Advertencia: ${errores.length} registro(s) con error`, 'warning')
      }

      vistaPrevia.value.mostrar = false

      // Recargar adeudos
      if (contratoActual.value) {
        await buscarAdeudos(contratoActual.value)
      }
    } catch (error) {
      hideLoading()
      showToast('Error al ejecutar operación', 'error')
      handleApiError(error)
    } finally {
      hideLoading()
    }
  }
}

const cancelarOperacion = () => {
  vistaPrevia.value.mostrar = false
}

const limpiarConfiguracion = () => {
  configuracion.value = {
    periodo_desde: '',
    periodo_hasta: '',
    tipo_aseo: '',
    tabla_recargos: 'actual',
    fecha_calculo: new Date().toISOString().split('T')[0],
    porcentaje_gastos: 0,
    meses_minimos: 3,
    nueva_cuota: 0,
    tipo_actualizacion: 'reemplazar',
    nuevo_status: 'V',
    motivo_cambio: '',
    factor_actualizacion: 0,
    base_calculo: 'total',
    formato: 'excel',
    incluir: 'todos'
  }
  vistaPrevia.value.mostrar = false
  resultados.value.mostrar = false
}

const formatCurrency = (value) => {
  return new Intl.NumberFormat('es-MX', { style: 'currency', currency: 'MXN' }).format(value || 0)
}

const openDocumentation = () => {
  showDocumentation.value = true
}
</script>
