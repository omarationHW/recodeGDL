<template>
  <div class="carga-valores-page">
    <h1>Carga de Valores</h1>
    <div class="breadcrumb">
      <router-link to="/">Inicio</router-link> / Carga de Valores
    </div>
    <div class="form-section">
      <label for="tabla-select"><strong>Tabla a Cargar Valores:</strong></label>
      <select v-model="selectedTabla" @change="onTablaChange" id="tabla-select">
        <option v-for="tabla in tablas" :key="tabla.cve_tab" :value="tabla.cve_tab">
          {{ tabla.cve_tab }} - {{ tabla.nombre }}
        </option>
      </select>
    </div>
    <div v-if="loading" class="loading">Cargando...</div>
    <div v-if="!loading">
      <table class="valores-grid">
        <thead>
          <tr>
            <th>Ejercicio</th>
            <th>Cve Und</th>
            <th>Cve Oper</th>
            <th>Descripción</th>
            <th>$ Costo</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(row, idx) in valores" :key="idx">
            <td><input v-model="row.ejercicio" type="number" min="2000" max="2100" /></td>
            <td><input v-model="row.cve_unidad" maxlength="10" /></td>
            <td><input v-model="row.cve_operatividad" maxlength="10" /></td>
            <td><input v-model="row.descripcion" maxlength="100" /></td>
            <td><input v-model.number="row.costo" type="number" min="0" step="0.01" /></td>
          </tr>
        </tbody>
      </table>
      <button @click="addRow">Agregar Fila</button>
      <button @click="removeRow" :disabled="valores.length <= 1">Eliminar Fila</button>
      <div class="actions">
        <button @click="aplicaValores" :disabled="!canApply">Aplicar</button>
        <button @click="$router.back()">Salir</button>
      </div>
      <div v-if="message" :class="{'success': success, 'error': !success}">{{ message }}</div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'CargaValoresPage',
  data() {
    return {
      tablas: [],
      selectedTabla: '',
      valores: [],
      loading: false,
      message: '',
      success: false
    };
  },
  computed: {
    canApply() {
      return this.selectedTabla && this.valores.some(row => row.ejercicio && row.cve_unidad && row.cve_operatividad && row.descripcion && row.costo > 0);
    }
  },
  methods: {
    async fetchTablas() {
      this.loading = true;
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action: 'get_tablas' })
      });
      const data = await res.json();
      this.tablas = data.data || [];
      if (this.tablas.length > 0) {
        this.selectedTabla = this.tablas[0].cve_tab;
        await this.onTablaChange();
      }
      this.loading = false;
    },
    async onTablaChange() {
      if (!this.selectedTabla) return;
      this.loading = true;
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action: 'get_unidades', params: { cve_tab: this.selectedTabla, ejercicio: new Date().getFullYear() } })
      });
      const data = await res.json();
      if (data.data && data.data.length > 0) {
        this.valores = data.data.map(u => ({
          ejercicio: u.ejercicio,
          cve_unidad: u.cve_unidad,
          cve_operatividad: u.cve_operatividad,
          descripcion: u.descripcion,
          costo: 0
        }));
      } else {
        // Default 10 empty rows
        this.valores = Array.from({ length: 10 }, () => ({ ejercicio: new Date().getFullYear(), cve_unidad: '', cve_operatividad: '', descripcion: '', costo: 0 }));
      }
      this.loading = false;
    },
    addRow() {
      this.valores.push({ ejercicio: new Date().getFullYear(), cve_unidad: '', cve_operatividad: '', descripcion: '', costo: 0 });
    },
    removeRow() {
      if (this.valores.length > 1) this.valores.pop();
    },
    async aplicaValores() {
      this.message = '';
      this.success = false;
      // Filter only filled rows
      const rows = this.valores.filter(row => row.ejercicio && row.cve_unidad && row.cve_operatividad && row.descripcion && row.costo > 0);
      if (rows.length === 0) {
        this.message = 'Debe capturar al menos un valor válido.';
        return;
      }
      this.loading = true;
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action: 'insert_valores', params: { valores: rows, cve_tab: this.selectedTabla } })
      });
      const data = await res.json();
      this.loading = false;
      this.success = data.success;
      this.message = data.message || (data.success ? 'Valores creados correctamente.' : 'Error al insertar valores.');
      if (data.success) {
        await this.onTablaChange();
      }
    }
  },
  mounted() {
    this.fetchTablas();
  }
};
</script>

<style scoped>
.carga-valores-page {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem;
}
.breadcrumb {
  margin-bottom: 1rem;
  color: #888;
}
.form-section {
  margin-bottom: 1rem;
}
.valores-grid {
  width: 100%;
  border-collapse: collapse;
  margin-bottom: 1rem;
}
.valores-grid th, .valores-grid td {
  border: 1px solid #ccc;
  padding: 0.3rem;
  text-align: left;
}
.actions {
  margin-top: 1rem;
}
.success {
  color: green;
  margin-top: 1rem;
}
.error {
  color: red;
  margin-top: 1rem;
}
.loading {
  color: #555;
  font-style: italic;
}
</style>
