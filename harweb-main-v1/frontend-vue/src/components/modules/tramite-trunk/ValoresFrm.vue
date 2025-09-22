<template>
  <div class="valores-page">
    <div class="breadcrumb">
      <router-link to="/">Inicio</router-link> / <span>Valores</span>
    </div>
    <h1>Valores de Cuenta</h1>
    <div class="actions">
      <button @click="startTransaction" :disabled="inTransaction">Iniciar Transacción</button>
      <button @click="cancelTransaction" :disabled="!inTransaction">Cancelar Transacción</button>
      <button @click="applyValores" :disabled="!inTransaction">Aplicar Cambios</button>
    </div>
    <form @submit.prevent="saveValor">
      <div class="form-row">
        <label>Año de Efectos</label>
        <input v-model.number="form.axoefec" :disabled="!inTransaction" type="number" min="1900" max="2100" required />
        <label>Bimestre</label>
        <input v-model.number="form.bimefec" :disabled="!inTransaction" type="number" min="1" max="6" required />
        <label>Valor Fiscal</label>
        <input v-model.number="form.valfiscal" :disabled="!inTransaction" type="number" step="0.01" required />
        <label>Tasa</label>
        <select v-model.number="form.tasa" :disabled="!inTransaction">
          <option v-for="t in tasas" :key="t.tasaporcen" :value="t.tasaporcen">{{ t.tasaporcen }}</option>
        </select>
        <label>Año Sobretasa</label>
        <input v-model.number="form.axosobre" :disabled="!inTransaction" type="number" min="0" />
      </div>
      <div class="form-row">
        <label>Observaciones</label>
        <textarea v-model="form.observacion" :disabled="!inTransaction"></textarea>
      </div>
      <div class="form-row">
        <button type="submit" :disabled="!inTransaction">{{ form.id ? 'Actualizar' : 'Agregar' }}</button>
        <button type="button" @click="resetForm" :disabled="!inTransaction">Limpiar</button>
      </div>
    </form>
    <h2>Valores Temporales</h2>
    <table class="valores-table">
      <thead>
        <tr>
          <th>Año</th>
          <th>Bimestre</th>
          <th>Valor Fiscal</th>
          <th>Tasa</th>
          <th>Año Sobretasa</th>
          <th>Estado</th>
          <th>Observación</th>
          <th>Acciones</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="v in valores" :key="v.id">
          <td>{{ v.axoefec }}</td>
          <td>{{ v.bimefec }}</td>
          <td>{{ v.valfiscal }}</td>
          <td>{{ v.tasa }}</td>
          <td>{{ v.axosobre }}</td>
          <td>
            <span :class="{'estado-nuevo': v.estado==='N', 'estado-modificado': v.estado==='M'}">{{ v.estado }}</span>
          </td>
          <td>{{ v.observacion }}</td>
          <td>
            <button @click="editValor(v)" :disabled="!inTransaction">Editar</button>
            <button @click="deleteValor(v)" :disabled="!inTransaction">Eliminar</button>
          </td>
        </tr>
      </tbody>
    </table>
    <div v-if="message" class="message">{{ message }}</div>
  </div>
</template>

<script>
export default {
  name: 'ValoresPage',
  data() {
    return {
      cvecuenta: null,
      valores: [],
      tasas: [],
      form: {
        id: null,
        axoefec: '',
        bimefec: '',
        valfiscal: '',
        tasa: '',
        axosobre: '',
        estado: 'N',
        observacion: ''
      },
      inTransaction: false,
      message: ''
    }
  },
  created() {
    // Suponiendo que la cuenta activa se obtiene de la ruta o store
    this.cvecuenta = this.$route.query.cvecuenta || 0;
    this.loadValores();
    this.loadTasas();
  },
  methods: {
    async api(action, payload) {
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action, payload })
      });
      return await res.json();
    },
    async loadValores() {
      const res = await this.api('listValores', { cvecuenta: this.cvecuenta });
      if (res.success) this.valores = res.data;
    },
    async loadTasas() {
      const year = new Date().getFullYear();
      const res = await this.api('getTasas', { axo: year });
      if (res.success) this.tasas = res.data;
    },
    startTransaction() {
      this.inTransaction = true;
      this.message = '';
    },
    cancelTransaction() {
      this.inTransaction = false;
      this.resetForm();
      this.message = 'Transacción cancelada.';
    },
    async saveValor() {
      if (!this.form.axoefec || !this.form.bimefec || !this.form.valfiscal || !this.form.tasa) {
        this.message = 'Todos los campos requeridos deben estar completos.';
        return;
      }
      let action = this.form.id ? 'updateValor' : 'insertValor';
      let payload = { ...this.form, cvecuenta: this.cvecuenta };
      const res = await this.api(action, payload);
      if (res.success) {
        this.message = 'Valor guardado correctamente.';
        this.resetForm();
        this.loadValores();
      } else {
        this.message = res.message;
      }
    },
    editValor(v) {
      this.form = { ...v };
      this.inTransaction = true;
    },
    async deleteValor(v) {
      if (!confirm('¿Seguro que desea eliminar este valor?')) return;
      const res = await this.api('deleteValor', { id: v.id });
      if (res.success) {
        this.message = 'Valor eliminado.';
        this.loadValores();
      } else {
        this.message = res.message;
      }
    },
    resetForm() {
      this.form = {
        id: null,
        axoefec: '',
        bimefec: '',
        valfiscal: '',
        tasa: '',
        axosobre: '',
        estado: 'N',
        observacion: ''
      };
    },
    async applyValores() {
      const res = await this.api('applyValores', { cvecuenta: this.cvecuenta });
      if (res.success) {
        this.message = 'Cambios aplicados correctamente.';
        this.inTransaction = false;
        this.loadValores();
      } else {
        this.message = res.message;
      }
    }
  }
}
</script>

<style scoped>
.valores-page { max-width: 900px; margin: 0 auto; padding: 2rem; }
.breadcrumb { margin-bottom: 1rem; }
.actions { margin-bottom: 1rem; }
.form-row { display: flex; gap: 1rem; margin-bottom: 1rem; }
.form-row label { min-width: 120px; }
.valores-table { width: 100%; border-collapse: collapse; margin-top: 1rem; }
.valores-table th, .valores-table td { border: 1px solid #ccc; padding: 0.5rem; }
.estado-nuevo { color: green; font-weight: bold; }
.estado-modificado { color: orange; font-weight: bold; }
.message { margin-top: 1rem; color: #007700; }
</style>
