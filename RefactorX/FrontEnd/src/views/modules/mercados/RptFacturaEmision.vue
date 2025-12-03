<template>
  <div style="padding: 20px;">
    <h1>TEST - Reporte Factura Emisión</h1>

    <div style="border: 2px solid blue; padding: 20px; margin: 20px 0;">
      <h3>Estado del Componente</h3>
      <p><strong>mostrarFiltros:</strong> {{ mostrarFiltros }}</p>
      <p><strong>Recaudadoras cargadas:</strong> {{ recaudadoras.length }}</p>
      <p><strong>Loading:</strong> {{ loading }}</p>
    </div>

    <div style="border: 2px solid green; padding: 20px; margin: 20px 0;">
      <div style="background: orange; color: white; padding: 10px; cursor: pointer;" @click="mostrarFiltros = !mostrarFiltros">
        <span v-if="mostrarFiltros">▼</span>
        <span v-else>►</span>
        Filtros de Consulta (Haz clic aquí)
      </div>

      <div v-show="mostrarFiltros" style="background: #f0f0f0; padding: 20px; margin-top: 10px;">
        <h4>FILTROS VISIBLES</h4>

        <div style="margin: 10px 0;">
          <label>Recaudadora:</label>
          <select v-model="filters.oficina" style="width: 100%; padding: 5px;">
            <option value="">Seleccione...</option>
            <option v-for="rec in recaudadoras" :key="rec.id_rec" :value="rec.id_rec">
              {{ rec.id_rec }} - {{ rec.recaudadora }}
            </option>
          </select>
          <p><small>Valor seleccionado: {{ filters.oficina || '(ninguno)' }}</small></p>
        </div>

        <div style="margin: 10px 0;">
          <label>Año:</label>
          <input type="number" v-model.number="filters.axo" style="width: 100%; padding: 5px;" />
          <p><small>Valor: {{ filters.axo }}</small></p>
        </div>

        <button @click="consultar" style="background: blue; color: white; padding: 10px 20px; border: none; cursor: pointer;">
          CONSULTAR
        </button>
      </div>
    </div>

    <div v-if="loading" style="border: 2px solid orange; padding: 20px; margin: 20px 0;">
      <p>⏳ Cargando...</p>
    </div>

    <div v-if="error" style="border: 2px solid red; padding: 20px; margin: 20px 0; color: red;">
      <h4>ERROR:</h4>
      <pre>{{ error }}</pre>
    </div>

    <div v-if="resultados.length" style="border: 2px solid green; padding: 20px; margin: 20px 0;">
      <h4>✅ RESULTADOS ({{ resultados.length }} registros)</h4>
      <pre>{{ JSON.stringify(resultados[0], null, 2) }}</pre>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import axios from 'axios';

const filters = ref({
  oficina: '',
  mercado: '',
  axo: new Date().getFullYear(),
  periodo: new Date().getMonth() + 1,
  opc: 1
});

const recaudadoras = ref([]);
const loading = ref(false);
const mostrarFiltros = ref(true);
const resultados = ref([]);
const error = ref(null);

const fetchRecaudadoras = async () => {
  loading.value = true;
  error.value = null;
  try {
    console.log('Intentando cargar recaudadoras...');
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_get_recaudadoras',
        Base: 'mercados',
        Parametros: []
      }
    });
    console.log('Respuesta recibida:', response.data);

    if (response.data.eResponse?.success && response.data.eResponse?.data?.result) {
      recaudadoras.value = response.data.eResponse.data.result;
      console.log('Recaudadoras cargadas:', recaudadoras.value.length);
    } else {
      error.value = 'No se encontraron recaudadoras en la respuesta';
    }
  } catch (err) {
    console.error('Error al cargar recaudadoras:', err);
    error.value = err.message || 'Error desconocido';
  } finally {
    loading.value = false;
  }
};

const consultar = async () => {
  loading.value = true;
  error.value = null;
  resultados.value = [];

  try {
    console.log('Consultando con filtros:', filters.value);
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_rpt_factura_emision',
        Base: 'mercados',
        Parametros: [
          { Nombre: 'p_oficina', Valor: parseInt(filters.value.oficina) || 1 },
          { Nombre: 'p_axo', Valor: parseInt(filters.value.axo) },
          { Nombre: 'p_periodo', Valor: parseInt(filters.value.periodo) },
          { Nombre: 'p_mercado', Valor: parseInt(filters.value.mercado) || 1 },
          { Nombre: 'p_opc', Valor: parseInt(filters.value.opc) }
        ]
      }
    });
    console.log('Respuesta recibida:', response.data);

    if (response.data.eResponse?.success && response.data.eResponse?.data?.result) {
      resultados.value = response.data.eResponse.data.result;
      console.log('Resultados:', resultados.value.length);
    } else {
      error.value = 'No se encontraron resultados';
    }
  } catch (err) {
    console.error('Error al consultar:', err);
    error.value = err.message || 'Error desconocido';
  } finally {
    loading.value = false;
  }
};

onMounted(() => {
  console.log('Componente montado, cargando recaudadoras...');
  fetchRecaudadoras();
});
</script>
