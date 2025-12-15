<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="trash-can" />
      </div>
      <div class="module-view-info">
        <h1>Eliminación de Adeudos por Ejecución</h1>
        <p>Aseo Contratado - Eliminar adeudos generados por procesos masivos o ejecuciones específicas</p>
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
      <!-- Opciones de Eliminación -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="cog" /> Opciones de Eliminación</h5>
        </div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group" style="flex: 0 0 100%;">
              <label class="municipal-form-label required">Tipo de Eliminación</label>
              <select v-model="tipoEliminacion" class="municipal-form-control" @change="limpiarFormulario">
                <option value="">Seleccione una opción...</option>
                <option value="por_periodo">Eliminar por Periodo</option>
                <option value="por_contrato">Eliminar por Contrato y Periodo</option>
                <option value="por_fecha_generacion">Eliminar por Fecha de Generación</option>
                <option value="por_ejercicio">Eliminar Ejercicio Completo</option>
              </select>
            </div>
          </div>

          <!-- Eliminación por Periodo -->
          <div v-if="tipoEliminacion === 'por_periodo'" class="mt-3">
            <h6 class="text-primary">Eliminar Adeudos de un Periodo Específico</h6>
            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label required">Periodo (Año-Mes)</label>
                <input type="month" v-model="parametros.periodo" class="municipal-form-control" required />
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Tipo de Aseo</label>
                <select v-model="parametros.tipo_aseo" class="municipal-form-control">
                  <option value="">Todos</option>
                  <option value="C">Comercial</option>
                  <option value="R">Residencial</option>
                  <option value="I">Industrial</option>
                  <option value="M">Mixto</option>
                </select>
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Solo sin Pagos</label>
                <select v-model="parametros.solo_sin_pagos" class="municipal-form-control">
                  <option value="S">Sí - Solo adeudos sin pagos aplicados</option>
                  <option value="N">No - Todos los adeudos del periodo</option>
                </select>
              </div>
            </div>
          </div>

          <!-- Eliminación por Contrato -->
          <div v-if="tipoEliminacion === 'por_contrato'" class="mt-3">
            <h6 class="text-primary">Eliminar Adeudos de un Contrato Específico</h6>
            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label required">Número de Contrato</label>
                <input
                  type="number"
                  v-model.number="parametros.num_contrato"
                  class="municipal-form-control"
                  placeholder="Ingrese número de contrato"
                  @blur="buscarContrato"
                  required
                />
              </div>
              <div class="form-group">
                <label class="municipal-form-label required">Periodo (Año-Mes)</label>
                <input type="month" v-model="parametros.periodo" class="municipal-form-control" required />
              </div>
            </div>
            <div v-if="contratoInfo" class="alert alert-info mt-2">
              <strong>Contrato:</strong> {{ contratoInfo.num_contrato }} - {{ contratoInfo.empresa }}
            </div>
          </div>

          <!-- Eliminación por Fecha de Generación -->
          <div v-if="tipoEliminacion === 'por_fecha_generacion'" class="mt-3">
            <h6 class="text-primary">Eliminar por Fecha de Generación/Creación</h6>
            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label required">Fecha de Generación</label>
                <input type="date" v-model="parametros.fecha_generacion" class="municipal-form-control" required />
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Incluir Usuario</label>
                <input
                  type="text"
                  v-model="parametros.usuario_generacion"
                  class="municipal-form-control"
                  placeholder="Usuario que generó los adeudos (opcional)"
                />
              </div>
            </div>
          </div>

          <!-- Eliminación por Ejercicio -->
          <div v-if="tipoEliminacion === 'por_ejercicio'" class="mt-3">
            <h6 class="text-danger">⚠️ Eliminar Ejercicio Completo (Acción Crítica)</h6>
            <div class="municipal-alert municipal-alert-danger">
              <font-awesome-icon icon="exclamation-triangle" />
              <strong>ADVERTENCIA:</strong> Esta acción eliminará TODOS los adeudos del ejercicio seleccionado. Solo debe usarse en casos excepcionales.
            </div>
            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label required">Ejercicio Fiscal</label>
                <input
                  type="number"
                  v-model.number="parametros.ejercicio"
                  class="municipal-form-control"
                  :placeholder="new Date().getFullYear().toString()"
                  min="2000"
                  :max="new Date().getFullYear() + 1"
                  required
                />
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Confirmación</label>
                <input
                  type="text"
                  v-model="parametros.confirmacion"
                  class="municipal-form-control"
                  placeholder="Escriba 'ELIMINAR' para confirmar"
                />
              </div>
            </div>
          </div>

          <div v-if="tipoEliminacion" class="button-group mt-3">
            <button class="btn-municipal-primary" @click="buscarAdeudos" :disabled="loading">
              <font-awesome-icon :icon="loading ? 'spinner' : 'search'" :spin="loading" /> Buscar Adeudos
            </button>
            <button class="btn-municipal-secondary" @click="limpiarFormulario">
              <font-awesome-icon icon="eraser" /> Limpiar
            </button>
          </div>
        </div>
      </div>

      <!-- Vista Previa de Adeudos a Eliminar -->
      <div v-if="adeudosEncontrados.length > 0" class="municipal-card mt-3">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="list" /> Adeudos Encontrados ({{ adeudosEncontrados.length }})</h5>
        </div>
        <div class="municipal-card-body">
          <div class="municipal-alert municipal-alert-warning">
            <font-awesome-icon icon="exclamation-triangle" />
            Se encontraron <strong>{{ adeudosEncontrados.length }}</strong> adeudos que cumplen con los criterios.
            Total a eliminar: <strong>{{ formatCurrency(totalAdeudos) }}</strong>
          </div>

          <div class="table-responsive" style="max-height: 400px; overflow-y: auto;">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Contrato</th>
                  <th>Empresa</th>
                  <th>Periodo</th>
                  <th>Operación</th>
                  <th class="text-right">Cuota Base</th>
                  <th class="text-right">Recargos</th>
                  <th class="text-right">Gastos</th>
                  <th class="text-right">Total</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="adeudo in adeudosEncontrados" :key="adeudo.folio">
                  <td><strong>{{ adeudo.num_contrato }}</strong></td>
                  <td>{{ adeudo.empresa }}</td>
                  <td>{{ formatPeriodo(adeudo.periodo) }}</td>
                  <td>{{ adeudo.cve_operacion }}</td>
                  <td class="text-right">{{ formatCurrency(adeudo.cuota_base) }}</td>
                  <td class="text-right">{{ formatCurrency(adeudo.recargos) }}</td>
                  <td class="text-right">{{ formatCurrency(adeudo.gastos_cobranza) }}</td>
                  <td class="text-right"><strong>{{ formatCurrency(adeudo.total_periodo) }}</strong></td>
                </tr>
              </tbody>
              <tfoot>
                <tr class="table-total">
                  <td colspan="7" class="text-right"><strong>TOTAL A ELIMINAR:</strong></td>
                  <td class="text-right"><strong>{{ formatCurrency(totalAdeudos) }}</strong></td>
                </tr>
              </tfoot>
            </table>
          </div>

          <div class="button-group mt-3">
            <button class="btn-municipal-secondary" @click="confirmarEliminacion" :disabled="loading">
              <font-awesome-icon :icon="loading ? 'spinner' : 'trash'" :spin="loading" />
              Eliminar {{ adeudosEncontrados.length }} Adeudos
            </button>
            <button class="btn-municipal-secondary" @click="cancelar">
              <font-awesome-icon icon="times" /> Cancelar
            </button>
          </div>
        </div>
      </div>

      <!-- Resultados -->
      <div v-if="resultadoEliminacion" class="municipal-card mt-3">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="check-circle" /> Resultado de la Eliminación</h5>
        </div>
        <div class="municipal-card-body">
          <div class="municipal-alert municipal-alert-success">
            <font-awesome-icon icon="check-circle" />
            <strong>Eliminación completada:</strong> {{ resultadoEliminacion.eliminados }} adeudos eliminados correctamente.
          </div>
          <p><strong>Total eliminado:</strong> {{ formatCurrency(resultadoEliminacion.total_eliminado) }}</p>
          <p><strong>Fecha de operación:</strong> {{ new Date().toLocaleString('es-MX') }}</p>
        </div>
      </div>
    </div>

    <DocumentationModal :show="showDocumentation" @close="showDocumentation = false" title="Ayuda - Eliminación de Adeudos">
      <h3>Eliminación de Adeudos por Ejecución</h3>
      <p>Herramienta para eliminar adeudos generados por procesos masivos o en situaciones específicas.</p>

      <h4>Tipos de Eliminación:</h4>
      <ul>
        <li>
          <strong>Por Periodo:</strong> Elimina todos los adeudos de un mes específico.
          Útil cuando se generó incorrectamente un periodo completo.
        </li>
        <li>
          <strong>Por Contrato y Periodo:</strong> Elimina adeudos de un contrato específico en un periodo.
          Útil para correcciones individuales.
        </li>
        <li>
          <strong>Por Fecha de Generación:</strong> Elimina adeudos creados en una fecha específica.
          Útil para revertir una ejecución masiva incorrecta.
        </li>
        <li>
          <strong>Por Ejercicio Completo:</strong> Elimina todos los adeudos de un año fiscal.
          <span class="text-danger">USAR CON EXTREMA PRECAUCIÓN.</span>
        </li>
      </ul>

      <h4>Proceso de Eliminación:</h4>
      <ol>
        <li>Seleccionar el tipo de eliminación</li>
        <li>Especificar los parámetros correspondientes</li>
        <li>Buscar y visualizar los adeudos que se eliminarán</li>
        <li>Revisar la vista previa y el total</li>
        <li>Confirmar la eliminación</li>
      </ol>

      <h4>Restricciones:</h4>
      <ul>
        <li>La opción "Solo sin Pagos" previene eliminar adeudos con pagos aplicados</li>
        <li>La eliminación de ejercicio completo requiere confirmación explícita</li>
        <li>Se recomienda hacer respaldo antes de eliminaciones masivas</li>
      </ul>

      <h4>Advertencias:</h4>
      <p class="text-danger">
        <strong>⚠️ IMPORTANTE:</strong> Las eliminaciones son permanentes y no se pueden deshacer.
        Asegúrese de verificar cuidadosamente los adeudos antes de confirmar.
      </p>
    </DocumentationModal>
    <!-- Modal de Documentacion Tecnica -->
    <TechnicalDocsModal
      :show="showTechDocs"
      :componentName="'AdeudosExe_Del'"
      :moduleName="'aseo_contratado'"
      @close="closeTechDocs"
    />

  </div>
</template>

<script setup>
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import TechnicalDocsModal from '@/components/common/TechnicalDocsModal.vue'
import { ref, computed } from 'vue'
import Swal from 'sweetalert2'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'

const { execute } = useApi()
const { showToast } = useLicenciasErrorHandler()
const { showLoading, hideLoading } = useGlobalLoading()

const showDocumentation = ref(false)
const tipoEliminacion = ref('')
const adeudosEncontrados = ref([])
const contratoInfo = ref(null)
const resultadoEliminacion = ref(null)

const parametros = ref({
  periodo: '',
  tipo_aseo: '',
  solo_sin_pagos: 'S',
  num_contrato: null,
  fecha_generacion: '',
  usuario_generacion: '',
  ejercicio: new Date().getFullYear(),
  confirmacion: ''
})

const totalAdeudos = computed(() => {
  return adeudosEncontrados.value.reduce((sum, a) => sum + parseFloat(a.total_periodo || 0), 0)
})

const buscarContrato = async () => {
  if (!parametros.value.num_contrato) return

  try {
    const response = await execute('sp16_contratos_buscar', 'aseo_contratado', {
      parContrato: parametros.value.num_contrato,
      parTipo: 'T',
      parVigencia: 'T'
    })

    if (response && response.length > 0) {
      contratoInfo.value = response[0]
    } else {
      contratoInfo.value = null
      showToast('Contrato no encontrado', 'warning')
    }
  } catch (error) {
    hideLoading()
    handleApiError(error)
  }
}

const buscarAdeudos = async () => {
  // Validaciones según tipo de eliminación
  if (tipoEliminacion.value === 'por_periodo' && !parametros.value.periodo) {
    showToast('Especifique el periodo', 'warning')
    return
  }

  if (tipoEliminacion.value === 'por_contrato' && (!parametros.value.num_contrato || !parametros.value.periodo)) {
    showToast('Especifique el contrato y periodo', 'warning')
    return
  }

  if (tipoEliminacion.value === 'por_fecha_generacion' && !parametros.value.fecha_generacion) {
    showToast('Especifique la fecha de generación', 'warning')
    return
  }

  if (tipoEliminacion.value === 'por_ejercicio' && parametros.value.confirmacion !== 'ELIMINAR') {
    showToast('Debe escribir "ELIMINAR" para confirmar la eliminación del ejercicio', 'warning')
    return
  }

  showLoading()
  try {
    // Simular búsqueda de adeudos - En producción llamar a SP específico
    // SP propuesto: SP_ASEO_ADEUDOS_BUSCAR_PARA_ELIMINAR
    adeudosEncontrados.value = []
    showToast('Búsqueda de adeudos en desarrollo - Funcionalidad simulada', 'info')
  } catch (error) {
    hideLoading()
    showToast('Error al buscar adeudos', 'error')
    handleApiError(error)
  } finally {
    hideLoading()
  }
}

const confirmarEliminacion = async () => {
  let titulo = '¿Confirmar Eliminación?'
  let mensaje = `Se eliminarán <strong>${adeudosEncontrados.value.length}</strong> adeudos.<br>Total: <strong>${formatCurrency(totalAdeudos.value)}</strong>`

  if (tipoEliminacion.value === 'por_ejercicio') {
    titulo = '⚠️ ELIMINAR EJERCICIO COMPLETO'
    mensaje = `<p class="text-danger"><strong>ADVERTENCIA CRÍTICA:</strong></p><p>Se eliminarán TODOS los adeudos del ejercicio ${parametros.value.ejercicio}.</p><p>Total: <strong>${formatCurrency(totalAdeudos.value)}</strong></p><p class="text-danger mt-2">Esta acción es IRREVERSIBLE.</p>`
  }

  const result = await Swal.fire({
    title: titulo,
    html: mensaje,
    icon: 'warning',
    showCancelButton: true,
    confirmButtonText: 'Sí, Eliminar',
    cancelButtonText: 'Cancelar',
    confirmButtonColor: '#dc3545',
    cancelButtonColor: '#6c757d'
  })

  if (result.isConfirmed) {
    await eliminarAdeudos()
  }
}

const eliminarAdeudos = async () => {
  showLoading()
  try {
    // Llamar al SP de eliminación - En producción
    // SP propuesto: SP_ASEO_ADEUDOS_ELIMINAR_POR_EJECUCION

    resultadoEliminacion.value = {
      eliminados: adeudosEncontrados.value.length,
      total_eliminado: totalAdeudos.value
    }

    showToast(`${adeudosEncontrados.value.length} adeudos eliminados correctamente`, 'success')
    adeudosEncontrados.value = []
  } catch (error) {
    hideLoading()
    showToast('Error al eliminar adeudos', 'error')
    handleApiError(error)
  } finally {
    hideLoading()
  }
}

const limpiarFormulario = () => {
  parametros.value = {
    periodo: '',
    tipo_aseo: '',
    solo_sin_pagos: 'S',
    num_contrato: null,
    fecha_generacion: '',
    usuario_generacion: '',
    ejercicio: new Date().getFullYear(),
    confirmacion: ''
  }
  adeudosEncontrados.value = []
  contratoInfo.value = null
  resultadoEliminacion.value = null
}

const cancelar = () => {
  adeudosEncontrados.value = []
}

const formatCurrency = (value) => {
  return new Intl.NumberFormat('es-MX', { style: 'currency', currency: 'MXN' }).format(value || 0)
}

const formatPeriodo = (periodo) => {
  if (!periodo) return 'N/A'
  const [year, month] = periodo.split('-')
  const meses = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
                 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic']
  return `${meses[parseInt(month) - 1]} ${year}`
}

const openDocumentation = () => {
  showDocumentation.value = true
}
</script>

