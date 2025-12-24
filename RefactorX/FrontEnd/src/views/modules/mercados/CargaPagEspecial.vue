<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="calendar-alt" />
      </div>
      <div class="module-view-info">
        <h1>Carga de Pagos Especial</h1>
        <p>Mercados - Años Anteriores sin Fecha de Ingreso</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-info" @click="showDocumentacion = true" title="Documentacion">
          <font-awesome-icon icon="book-open" />
          <span>Documentacion</span>
        </button>
        <button class="btn-municipal-purple" @click="showAyuda = true" title="Ayuda">
          <font-awesome-icon icon="question-circle" />
          <span>Ayuda</span>
        </button>
        
        </div>
    </div>

    <div class="module-view-content">
      <div class="container-fluid">
        <div class="row">
          <div class="municipal-card-body">

            <!-- Selección de Mercado -->
            <div class="col-md-1">
              <div class="municipal-card mb-3">
                <div class="municipal-card-header">
                  <h5>
                    <font-awesome-icon icon="store" />
                    Mercado
                  </h5>
                </div>
                <div class="municipal-card-body">
                  <div class="row">
                    <div class="col-md-3 mb-3">
                      <label class="municipal-form-label">Seleccione Mercado *</label>
                      <select class="municipal-form-control" v-model="selectedMercado" @change="onMercadoChange"
                        :disabled="loading">
                        <option :value="null">Seleccione...</option>
                        <option v-for="m in mercados" :key="m.num_mercado_nvo" :value="m">
                          {{ m.num_mercado_nvo }} - {{ m.descripcion }}
                        </option>
                      </select>
                    </div>
                  </div>

                  <!-- Datos del Pago -->
                  <div class="col-md-12">
                    <div class="municipal-card mb-3">
                      <div class="municipal-card-header">
                        <h5>
                          <font-awesome-icon icon="credit-card" />
                          Datos del Pago
                        </h5>
                      </div>
                      <div class="row">
                        <div class="col-md-3 mb-3">
                          <label class="municipal-form-label">Oficina *</label>
                          <input type="number" class="municipal-form-control" v-model.number="form.oficina_pago"
                            :disabled="loading" min="1" />
                        </div>
                        <div class="col-md-3 mb-3">
                          <label class="municipal-form-label">Caja *</label>
                          <input type="text" class="municipal-form-control" v-model="form.caja_pago" :disabled="loading"
                            maxlength="2" />
                        </div>
                        <div class="col-md-3 mb-3">
                          <label class="municipal-form-label">Operación *</label>
                          <input type="number" class="municipal-form-control" v-model.number="form.operacion_pago"
                            :disabled="loading" min="1" />
                        </div>
                        <div class="col-md-3 mb-3">
                          <label class="municipal-form-label">Fecha Pago *</label>
                          <input type="date" class="municipal-form-control" v-model="form.fecha_pago"
                            :disabled="loading" />
                        </div>
                      </div>
                      <div class="row">
                        <div class="col-md-4 mb-3">
                          <label class="municipal-form-label">Local *</label>
                          <input type="number" class="municipal-form-control" v-model.number="form.local"
                            :disabled="loading" min="1" />
                        </div>
                        <div class="col-md-8 mb-3 d-flex align-items-end">
                          <button class="btn-municipal-primary" @click="buscarAdeudos"
                            :disabled="!puedesBuscar || loading">
                            <span v-if="loading" class="spinner-border spinner-border-sm me-1"></span>
                            <font-awesome-icon icon="search" v-if="!loading" />
                            Buscar Adeudos
                          </button>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Tabla de Adeudos -->
        <div v-if="adeudos.length > 0" class="municipal-card">
          <div class="municipal-card-header">
            <h5>
              <font-awesome-icon icon="list" />
              Adeudos del Local
              <span class="badge bg-primary ms-2">{{ adeudos.length }}</span>
            </h5>
          </div>
          <div class="municipal-card-body">
            <div class="table-responsive">
              <table class="municipal-table table-sm">
                <thead>
                  <tr>
                    <th>Control</th>
                    <th>Rec</th>
                    <th>Merc</th>
                    <th>Cat</th>
                    <th>Sec</th>
                    <th>Local</th>
                    <th>Letra</th>
                    <th>Bloque</th>
                    <th>Año</th>
                    <th>Mes</th>
                    <th>Renta</th>
                    <th>Partida</th>
                    <th>Sel</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="(a, idx) in adeudos" :key="`${a.id_local}-${a.axo}-${a.periodo}`">
                    <td>{{ a.id_local }}</td>
                    <td>{{ a.oficina }}</td>
                    <td>{{ a.num_mercado }}</td>
                    <td>{{ a.categoria }}</td>
                    <td>{{ a.seccion }}</td>
                    <td>{{ a.local }}</td>
                    <td>{{ a.letra_local }}</td>
                    <td>{{ a.bloque }}</td>
                    <td>{{ a.axo }}</td>
                    <td>{{ a.periodo }}</td>
                    <td>
                      <input type="number" class="form-control form-control-sm" v-model.number="a.importe"
                        style="width: 80px;" step="0.01" />
                    </td>
                    <td>
                      <input type="text" class="form-control form-control-sm" v-model="a.partida" placeholder="Partida"
                        maxlength="20" style="width: 80px;" />
                    </td>
                    <td>
                      <input type="checkbox" v-model="a.selected" />
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>

            <div class="d-flex justify-content-end gap-2 mt-3">
              <button class="btn-municipal-primary" @click="cargarPagos" :disabled="!hayPagosValidos || loading">
                <span v-if="loading" class="spinner-border spinner-border-sm me-1"></span>
                <font-awesome-icon icon="save" v-if="!loading" />
                Cargar Pagos
              </button>
              <button class="btn-municipal-secondary" @click="limpiar" :disabled="loading">
                <font-awesome-icon icon="eraser" />
                Limpiar
              </button>
            </div>
          </div>
        </div>

        <!-- Sin resultados -->
        <div v-if="adeudos.length === 0 && !loading" class="municipal-card">
          <div class="municipal-card-body text-center py-4 text-muted">
            <font-awesome-icon icon="inbox" size="3x" class="mb-3" />
            <p>Seleccione un mercado y local, luego presione "Buscar Adeudos".</p>
          </div>
        </div>
      </div>
    </div>
  </div>

  <DocumentationModal :show="showAyuda" :component-name="'CargaPagEspecial'" :module-name="'mercados'" :doc-type="'ayuda'" :title="'Mercados - CargaPagEspecial'" @close="showAyuda = false" />
  <DocumentationModal :show="showDocumentacion" :component-name="'CargaPagEspecial'" :module-name="'mercados'" :doc-type="'documentacion'" :title="'Mercados - CargaPagEspecial'" @close="showDocumentacion = false" />
</template>

<script setup>
import apiService from '@/services/apiService';
import { ref, computed, onMounted } from 'vue';
import { useRouter } from 'vue-router';
import Swal from 'sweetalert2';
import { library } from '@fortawesome/fontawesome-svg-core';
import {
  faCalendarAlt, faStore, faSearch, faList, faSave, faTimes,
  faQuestionCircle, faEraser, faInbox, faCreditCard
} from '@fortawesome/free-solid-svg-icons';
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';
import { useGlobalLoading } from '@/composables/useGlobalLoading';
import { useToast } from '@/composables/useToast';
import DocumentationModal from '@/components/common/DocumentationModal.vue'

const showAyuda = ref(false)
const showDocumentacion = ref(false)


library.add(
  faCalendarAlt, faStore, faSearch, faList, faSave, faTimes,
  faQuestionCircle, faEraser, faInbox, faCreditCard
);

const router = useRouter();
const globalLoading = useGlobalLoading();
const { showToast } = useToast();

// Estados
const loading = ref(false);
const mercados = ref([]);
const selectedMercado = ref(null);
const adeudos = ref([]);

// Formulario
const form = ref({
  oficina_pago: '',
  caja_pago: '',
  operacion_pago: '',
  fecha_pago: new Date().toISOString().split('T')[0],
  local: ''
});

// Computed
const puedesBuscar = computed(() => {
  return selectedMercado.value && form.value.local;
});

const hayPagosValidos = computed(() => {
  return adeudos.value.some(a =>
    a.selected && a.partida && a.partida.trim() !== '' && a.partida !== '0'
  );
});

// Cargar datos iniciales
onMounted(() => {
  cargarMercados();
});

// Cargar mercados
async function cargarMercados() {
  await globalLoading.withLoading(async () => {
    try {
      const response = await apiService.execute(
          'sp_get_catalogo_mercados',
          'mercados',
          [],
          '',
          null,
          'publico'
        );

      if (response.success && response.data?.result) {
        mercados.value = response.data.result;
      }
    } catch (error) {
      console.error('Error al cargar mercados:', error);
      showToast('Error al cargar mercados', 'error');
    }
  }, 'Cargando mercados', 'Por favor espere...');
}

// Cuando cambia el mercado
function onMercadoChange() {
  if (selectedMercado.value) {
    form.value.oficina_pago = selectedMercado.value.oficina;
  }
  form.value.local = '';
  adeudos.value = [];
}

// Buscar adeudos
async function buscarAdeudos() {
  if (!selectedMercado.value || !form.value.local) {
    showToast('Seleccione un mercado y local válido', 'warning');
    return;
  }

  loading.value = true;
  adeudos.value = [];

  try {
    await globalLoading.withLoading(async () => {
      const response = await apiService.execute(
          'sp_get_adeudos_local_params',
          'mercados',
          [
            { nombre: 'p_oficina', valor: selectedMercado.value.oficina },
            { nombre: 'p_mercado', valor: selectedMercado.value.num_mercado_nvo },
            { nombre: 'p_categoria', valor: selectedMercado.value.categoria },
            { nombre: 'p_seccion', valor: 'SS' },
            { nombre: 'p_local', valor: parseInt(form.value.local) }
          ],
          '',
          null,
          'publico'
        );

      if (response.success && response.data?.result) {
        adeudos.value = response.data.result.map(a => ({
          ...a,
          selected: true,
          partida: ''
        }));

        if (adeudos.value.length === 0) {
          showToast('No se encontraron adeudos para este local', 'info');
        } else {
          showToast(`Se encontraron ${adeudos.value.length} adeudos`, 'success');
        }
      } else {
        showToast('No se encontraron adeudos', 'info');
      }
    }, 'Buscando adeudos', 'Por favor espere...');
  } catch (error) {
    console.error('Error al buscar adeudos:', error);
    showToast('Error al buscar adeudos', 'error');
  } finally {
    loading.value = false;
  }
}

// Cargar pagos
async function cargarPagos() {
  const pagosValidos = adeudos.value.filter(a =>
    a.selected && a.partida && a.partida.trim() !== '' && a.partida !== '0'
  );

  if (pagosValidos.length === 0) {
    showToast('Debe seleccionar al menos un adeudo y capturar la partida', 'warning');
    return;
  }

  if (!form.value.fecha_pago || !form.value.oficina_pago ||
    !form.value.caja_pago || !form.value.operacion_pago) {
    showToast('Complete todos los datos del pago', 'warning');
    return;
  }

  const result = await Swal.fire({
    title: '¿Cargar pagos?',
    text: `Se cargarán ${pagosValidos.length} pagos especiales`,
    icon: 'question',
    showCancelButton: true,
    confirmButtonText: 'Sí, cargar',
    cancelButtonText: 'Cancelar'
  });

  if (!result.isConfirmed) return;

  loading.value = true;

  try {
    await globalLoading.withLoading(async () => {
      const pagosJson = pagosValidos.map(a => ({
        id_local: a.id_local,
        axo: a.axo,
        periodo: a.periodo,
        importe: a.importe,
        partida: a.partida
      }));

      const response = await apiService.execute(
          'sp_cargar_pagos_especial',
          'mercados',
          [
            { nombre: 'p_pagos_json', valor: JSON.stringify(pagosJson) },
            { nombre: 'p_fecha_pago', valor: form.value.fecha_pago },
            { nombre: 'p_oficina_pago', valor: parseInt(form.value.oficina_pago) },
            { nombre: 'p_caja_pago', valor: form.value.caja_pago },
            { nombre: 'p_operacion_pago', valor: parseInt(form.value.operacion_pago) },
            { nombre: 'p_usuario_id', valor: 1 } // TODO: Obtener de sesión
          ],
          '',
          null,
          'publico'
        );

      if (response.success) {
        showToast(`${pagosValidos.length} pagos cargados correctamente`, 'success');
        adeudos.value = [];
      }
    }, 'Cargando pagos especiales', 'Por favor espere...');
  } catch (error) {
    console.error('Error al cargar pagos:', error);
    showToast('Error al cargar pagos', 'error');
  } finally {
    loading.value = false;
  }
}

// Limpiar
function limpiar() {
  adeudos.value = [];
  form.value.local = '';
}

// Mostrar ayuda
function mostrarAyuda() {
  Swal.fire({
    title: 'Ayuda - Carga de Pagos Especial',
    html: `
      <div style="text-align: left;">
        <h6>Instrucciones:</h6>
        <ol>
          <li>Seleccione el mercado de la lista</li>
          <li>Complete los datos del pago (oficina, caja, operación, fecha)</li>
          <li>Ingrese el número de local y presione "Buscar Adeudos"</li>
          <li>Capture el número de partida para cada adeudo a pagar</li>
          <li>Puede modificar el importe de la renta si es necesario</li>
          <li>Marque/desmarque los adeudos que desea pagar</li>
          <li>Presione "Cargar Pagos" para registrar</li>
        </ol>
        <p><strong>Nota:</strong> Esta pantalla es para pagos de años anteriores sin fecha de ingreso. Se aplica un 10% de descuento para octubre 2005.</p>
      </div>
    `,
    icon: 'info',
    confirmButtonText: 'Entendido'
  });
}</script>

<!--
  Estilos removidos - Se usan clases globales municipales:
  - .gap-2: Bootstrap utility class (ya está disponible globalmente)
  - .table-sm: Bootstrap utility class (ya está disponible globalmente)
  - .badge: Bootstrap utility class (ya está disponible globalmente)
  - Los estilos de tabla están cubiertos por .municipal-table
-->
