<template>
  <div class="module-view module-layout">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="credit-card" />
      </div>
      <div class="module-view-info">
        <h1>Paga Licencias</h1>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-info" @click="showDocumentacion = true">
          <font-awesome-icon icon="book" />
          Documentacion
        </button>
        <button class="btn-municipal-purple" @click="showAyuda = true">
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Número de Licencia</label>
              <input
                class="municipal-form-control"
                v-model="filters.licencia"
                @keyup.enter="pagar"
                placeholder="Ej: 100, 00150, LC-2024-001"
              />
              <div v-if="errorMessage" class="alert-error">
                <font-awesome-icon icon="exclamation-triangle" />
                {{ errorMessage }}
              </div>
              <div v-if="successMessage" class="alert-success">
                <font-awesome-icon icon="check-circle" />
                {{ successMessage }}
              </div>
            </div>
          </div>

          <div class="button-group">
            <button class="btn-municipal-primary" :disabled="loading" @click="pagar">
              <font-awesome-icon icon="credit-card" v-if="!loading" />
              <font-awesome-icon icon="spinner" spin v-if="loading" />
              {{ loading ? 'Procesando...' : 'Pagar' }}
            </button>
            <button class="btn-municipal-secondary" :disabled="loading" @click="limpiar">
              <font-awesome-icon icon="eraser" />
              Limpiar
            </button>
          </div>
        </div>
      </div>

      <!-- Resultado del Pago -->
      <div class="municipal-card" v-if="paymentResult && successMessage">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="check-circle" class="text-success" />
            Detalles del Pago
          </h5>
        </div>
        <div class="municipal-card-body">
          <div class="result-grid">
            <div class="result-item">
              <label class="result-label">Número de Licencia:</label>
              <div class="result-value"><strong>{{ paymentResult.licencia }}</strong></div>
            </div>
            <div class="result-item">
              <label class="result-label">Contribuyente:</label>
              <div class="result-value">{{ paymentResult.contribuyente }}</div>
            </div>
            <div class="result-item">
              <label class="result-label">Monto Pagado:</label>
              <div class="result-value monto-pagado">{{ formatCurrency(paymentResult.monto) }}</div>
            </div>
            <div class="result-item">
              <label class="result-label">Folio/Referencia:</label>
              <div class="result-value"><code>{{ paymentResult.folio }}</code></div>
            </div>
            <div class="result-item">
              <label class="result-label">Fecha de Pago:</label>
              <div class="result-value">{{ paymentResult.fecha }}</div>
            </div>
            <div class="result-item">
              <label class="result-label">Estado:</label>
              <div class="result-value">
                <span class="status-badge status-success">{{ paymentResult.estado }}</span>
              </div>
            </div>
          </div>

          <!-- Información adicional si existe -->
          <div v-if="paymentResult.observaciones || paymentResult.nota" class="additional-info">
            <label class="result-label">Observaciones:</label>
            <div class="result-value">{{ paymentResult.observaciones || paymentResult.nota }}</div>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showAyuda"
      :component-name="'pagalicfrm'"
      :module-name="'multas_reglamentos'"
      :doc-type="'ayuda'"
      :title="'Paga Licencias'"
      @close="showAyuda = false"
    />

    <!-- Modal de Documentacion -->
    <DocumentationModal
      :show="showDocumentacion"
      :component-name="'pagalicfrm'"
      :module-name="'multas_reglamentos'"
      :doc-type="'documentacion'"
      :title="'Paga Licencias'"
      @close="showDocumentacion = false"
    />

  </div>
</template>

<script setup>
import { ref } from 'vue';
import { useApi } from '@/composables/useApi'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import DocumentationModal from '@/components/common/DocumentationModal.vue';
// Estados para modales de documentacion
const showAyuda = ref(false)
const showDocumentacion = ref(false)

const { loading, execute } = useApi();
const { showLoading, hideLoading } = useGlobalLoading();
const BASE_DB = 'multas_reglamentos';
const OP = 'RECAUDADORA_PAGALICFRM';
const SCHEMA = 'publico';

const filters = ref({
  licencia: ''
});

const errorMessage = ref('');
const successMessage = ref('');
const paymentResult = ref(null);

async function pagar() {
  // Validar que el campo no esté vacío
  const licencia = String(filters.value.licencia || '').trim();

  if (!licencia) {
    errorMessage.value = 'Por favor ingrese un número de licencia';
    setTimeout(() => {
      errorMessage.value = '';
    }, 3000);
    return;
  }

  // Limpiar mensajes previos
  errorMessage.value = '';
  successMessage.value = '';
  paymentResult.value = null;

  try {
    // Crear una promesa con timeout de 10 segundos
    const timeoutPromise = new Promise((_, reject) => {
      setTimeout(() => reject(new Error('TIMEOUT')), 10000);
    });

    // Ejecutar la petición con timeout
    const executePromise = execute(OP, BASE_DB, [
      { name: 'licencia', type: 'C', value: licencia }
    ], '', null, SCHEMA);

    // Race entre la petición y el timeout
    const response = await Promise.race([executePromise, timeoutPromise]);

    console.log('Respuesta del pago:', response);

    // Extraer datos de la respuesta
    const result = Array.isArray(response?.result) ? response.result[0] :
                   Array.isArray(response) ? response[0] :
                   response?.result || response || {};

    // Guardar el resultado para mostrarlo
    paymentResult.value = {
      licencia: result.licencia || result.numero_licencia || licencia,
      contribuyente: result.contribuyente || result.nombre || 'N/A',
      monto: result.monto || result.total || result.importe || 0,
      folio: result.folio || result.folio_pago || result.referencia || 'N/A',
      fecha: result.fecha || result.fecha_pago || new Date().toLocaleDateString('es-MX'),
      estado: result.estado || result.estatus || 'PAGADO',
      ...result
    };

    // Si la operación fue exitosa
    successMessage.value = 'Pago procesado exitosamente';
  } catch (e) {
    console.error('Error al procesar el pago:', e);

    if (e.message === 'TIMEOUT') {
      errorMessage.value = 'La operación está tardando demasiado. Por favor contacte al administrador para optimizar la base de datos.';
    } else {
      errorMessage.value = 'Error al procesar el pago. Por favor intente nuevamente.';
    }

    setTimeout(() => {
      errorMessage.value = '';
    }, 8000);
  }
}

function limpiar() {
  filters.value = { licencia: '' };
  errorMessage.value = '';
  successMessage.value = '';
  paymentResult.value = null;
}

function formatCurrency(v) {
  return Number(v || 0).toLocaleString('es-MX', { style: 'currency', currency: 'MXN' });
}
</script>

