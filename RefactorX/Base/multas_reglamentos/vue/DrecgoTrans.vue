<template>
  <div class="drecgo-trans-page">
    <nav class="breadcrumb">
      <router-link to="/">Inicio</router-link>
      <span>/</span>
      <span>Descuentos Recargos Transmisiones</span>
    </nav>
    <h1>Descuentos en Recargos de Transmisiones Patrimoniales</h1>
    <form @submit.prevent="onBuscar">
      <div class="form-row">
        <label for="folio">Folio de Transmisión:</label>
        <input v-model="folio" id="folio" type="number" required />
        <label for="tipo">Tipo:</label>
        <select v-model="tipo" id="tipo">
          <option value="completa">Completa</option>
          <option value="diferencia">Diferencias</option>
        </select>
        <button type="submit">Buscar</button>
      </div>
    </form>
    <div v-if="busqueda.length">
      <h2>Resultados</h2>
      <table class="result-table">
        <thead>
          <tr>
            <th>Folio</th>
            <th>Base Impuesto</th>
            <th>Recargos</th>
            <th>Multas</th>
            <th>Total</th>
            <th>Estado</th>
            <th>Acción</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in busqueda" :key="row.folio">
            <td>{{ row.folio }}</td>
            <td>{{ row.baseimpuesto }}</td>
            <td>{{ row.recargos }}</td>
            <td>{{ row.multas }}</td>
            <td>{{ row.total }}</td>
            <td>{{ row.estado }}</td>
            <td>
              <button v-if="row.estado === 'V'" @click="abrirAlta(row)">Alta Descuento</button>
              <button v-if="row.estado === 'V' && row.id_descto" @click="cancelarDescuento(row)">Cancelar</button>
              <span v-if="row.estado !== 'V'">No disponible</span>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    <div v-if="showAlta">
      <h2>Alta de Descuento</h2>
      <form @submit.prevent="onAlta">
        <div class="form-row">
          <label for="porcentaje">Porcentaje:</label>
          <input v-model.number="altaForm.porcentaje" id="porcentaje" type="number" min="1" max="100" required />
        </div>
        <div class="form-row">
          <label for="autoriza">Autoriza:</label>
          <select v-model="altaForm.autoriza" id="autoriza" required>
            <option v-for="aut in autorizadores" :key="aut.cveautoriza" :value="aut.cveautoriza">
              {{ aut.descripcion }}
            </option>
          </select>
        </div>
        <div class="form-row">
          <label for="observaciones">Observaciones:</label>
          <textarea v-model="altaForm.observaciones" id="observaciones"></textarea>
        </div>
        <button type="submit">Guardar</button>
        <button type="button" @click="showAlta = false">Cancelar</button>
      </form>
    </div>
    <div v-if="mensaje" class="mensaje">
      {{ mensaje }}
    </div>
  </div>
</template>

<script>
export default {
  name: 'DrecgoTransPage',
  data() {
    return {
      folio: '',
      tipo: 'completa',
      busqueda: [],
      showAlta: false,
      altaForm: {
        folio: '',
        porcentaje: 0,
        observaciones: '',
        autoriza: ''
      },
      autorizadores: [],
      mensaje: ''
    };
  },
  methods: {
    async onBuscar() {
      this.mensaje = '';
      this.busqueda = [];
      this.showAlta = false;
      let action = this.tipo === 'diferencia' ? 'search_diferencia' : 'search_folio';
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          eRequest: {
            action,
            params: { folio: this.folio, tipo: this.tipo }
          }
        })
      });
      const data = await res.json();
      if (data.eResponse.success) {
        this.busqueda = data.eResponse.data;
        if (!this.busqueda.length) this.mensaje = 'No se encontraron resultados.';
      } else {
        this.mensaje = data.eResponse.message;
      }
    },
    async abrirAlta(row) {
      this.showAlta = true;
      this.altaForm.folio = row.folio;
      this.altaForm.porcentaje = 0;
      this.altaForm.observaciones = '';
      await this.getAutorizadores();
    },
    async getAutorizadores() {
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          eRequest: {
            action: 'get_autorizadores',
            params: { user: '' }
          }
        })
      });
      const data = await res.json();
      if (data.eResponse.success) {
        this.autorizadores = data.eResponse.data;
      } else {
        this.mensaje = data.eResponse.message;
      }
    },
    async onAlta() {
      this.mensaje = '';
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          eRequest: {
            action: 'alta_descuento',
            params: {
              folio: this.altaForm.folio,
              porcentaje: this.altaForm.porcentaje,
              observaciones: this.altaForm.observaciones,
              autoriza: this.altaForm.autoriza
            }
          }
        })
      });
      const data = await res.json();
      if (data.eResponse.success) {
        this.mensaje = 'Descuento registrado correctamente.';
        this.showAlta = false;
        this.onBuscar();
      } else {
        this.mensaje = data.eResponse.message;
      }
    },
    async cancelarDescuento(row) {
      if (!confirm('¿Está seguro de cancelar el descuento?')) return;
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          eRequest: {
            action: 'cancelar_descuento',
            params: { folio: row.folio, id_descto: row.id_descto }
          }
        })
      });
      const data = await res.json();
      if (data.eResponse.success) {
        this.mensaje = 'Descuento cancelado correctamente.';
        this.onBuscar();
      } else {
        this.mensaje = data.eResponse.message;
      }
    }
  }
};
</script>

<style scoped>
.drecgo-trans-page {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem;
}
.breadcrumb {
  margin-bottom: 1rem;
}
.form-row {
  display: flex;
  align-items: center;
  gap: 1rem;
  margin-bottom: 1rem;
}
.result-table {
  width: 100%;
  border-collapse: collapse;
  margin-bottom: 2rem;
}
.result-table th, .result-table td {
  border: 1px solid #ccc;
  padding: 0.5rem;
}
.mensaje {
  color: #b00;
  font-weight: bold;
  margin-top: 1rem;
}
</style>
