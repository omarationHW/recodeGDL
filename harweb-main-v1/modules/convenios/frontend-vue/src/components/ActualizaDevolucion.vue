<template>
  <div class="actualiza-devolucion-page">
    <h1>Actualización de Devoluciones de Pago</h1>
    <div class="actions">
      <input type="file" @change="onFileChange" accept=".txt,.csv" />
      <button @click="previewGrid" :disabled="!rawFile">Previsualizar</button>
      <button @click="processGrid" :disabled="!grid.length">Actualizar</button>
    </div>
    <div v-if="grid.length">
      <h2>Previsualización</h2>
      <table class="devolucion-grid">
        <thead>
          <tr>
            <th v-for="(col, idx) in grid[0]" :key="'h'+idx">{{ col }}</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(row, i) in grid.slice(1)" :key="i">
            <td v-for="(col, j) in row" :key="j">{{ col }}</td>
          </tr>
        </tbody>
      </table>
    </div>
    <div v-if="result">
      <h3>Resultado</h3>
      <div v-if="result.success" class="success">{{ result.message }}</div>
      <div v-else class="error">{{ result.message }}</div>
      <ul v-if="result.data && result.data.errores">
        <li v-for="(err, idx) in result.data.errores" :key="idx">{{ err }}</li>
      </ul>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue';
import axios from 'axios';

const rawFile = ref(null);
const grid = ref([]);
const result = ref(null);
const userId = 1; // Debe obtenerse del contexto de sesión

function onFileChange(e) {
  const file = e.target.files[0];
  if (!file) return;
  const reader = new FileReader();
  reader.onload = function(evt) {
    const content = evt.target.result;
    rawFile.value = btoa(content);
  };
  reader.readAsText(file);
}

async function previewGrid() {
  if (!rawFile.value) return;
  const { data } = await axios.post('/api/execute', {
    eRequest: {
      action: 'uploadDevolucionFile',
      payload: { file_content: rawFile.value }
    }
  });
  if (data.eResponse.success) {
    grid.value = data.eResponse.data;
    result.value = null;
  } else {
    result.value = data.eResponse;
  }
}

async function processGrid() {
  if (!grid.value.length) return;
  const { data } = await axios.post('/api/execute', {
    eRequest: {
      action: 'processDevolucionGrid',
      payload: {
        grid: grid.value,
        user_id: userId
      }
    }
  });
  result.value = data.eResponse;
}
</script>

<style scoped>
.actualiza-devolucion-page {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem;
}
.actions {
  margin-bottom: 1rem;
}
.devolucion-grid {
  width: 100%;
  border-collapse: collapse;
}
.devolucion-grid th, .devolucion-grid td {
  border: 1px solid #ccc;
  padding: 0.3rem 0.5rem;
  font-size: 0.95rem;
}
.success { color: green; }
.error { color: red; }
</style>
