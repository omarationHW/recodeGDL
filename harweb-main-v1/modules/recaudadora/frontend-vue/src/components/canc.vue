<template>
  <div class="cancelacion-rango">
    <h1>Cancelación/Reasignación de Folios en Rango</h1>
    <form @submit.prevent="buscarFolios">
      <div class="form-row">
        <label>Tipo de Requerimiento:</label>
        <select v-model="form.tipo" required>
          <option value="predial">Predial</option>
          <option value="multas">Multas</option>
          <option value="licencias">Licencias</option>
          <option value="anuncios">Anuncios</option>
          <option value="diferencias">Diferencias Transmisión</option>
        </select>
      </div>
      <div class="form-row">
        <label>Recaudadora:</label>
        <input v-model.number="form.recaud" type="number" min="1" required />
      </div>
      <div class="form-row">
        <label>Folio Inicial:</label>
        <input v-model.number="form.folio_ini" type="number" min="1" required />
        <label>Folio Final:</label>
        <input v-model.number="form.folio_fin" type="number" min="1" required />
      </div>
      <button type="submit">Buscar Folios</button>
    </form>

    <div v-if="folios.length">
      <h2>Folios Encontrados</h2>
      <table class="table">
        <thead>
          <tr>
            <th>Folio</th>
            <th>Cuenta</th>
            <th>Ejecutor</th>
            <th>Vigencia</th>
            <th>Acción</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="folio in folios" :key="folio.folioreq">
            <td>{{ folio.folioreq }}</td>
            <td>{{ folio.cvecuenta }}</td>
            <td>{{ folio.cveejecut || '-' }}</td>
            <td>{{ folio.vigencia }}</td>
            <td>
              <button @click="seleccionarFolio(folio)">Seleccionar</button>
            </td>
          </tr>
        </tbody>
      </table>
      <div class="actions">
        <button @click="abrirCancelar">Cancelar Folios Seleccionados</button>
        <button @click="abrirReasignar">Reasignar Folios</button>
      </div>
    </div>

    <div v-if="showCancelar">
      <h3>Cancelar Folios</h3>
      <form @submit.prevent="cancelarFolios">
        <div class="form-row">
          <label>Motivo de Cancelación:</label>
          <textarea v-model="cancelarForm.motivo" required></textarea>
        </div>
        <div class="form-row">
          <label>Usuario:</label>
          <input v-model="cancelarForm.usuario" required />
        </div>
        <button type="submit">Confirmar Cancelación</button>
        <button type="button" @click="showCancelar=false">Cancelar</button>
      </form>
    </div>

    <div v-if="showReasignar">
      <h3>Reasignar Folios</h3>
      <form @submit.prevent="reasignarFolios">
        <div class="form-row">
          <label>Ejecutor Actual:</label>
          <input v-model.number="reasignarForm.ejecutor_actual" type="number" required />
        </div>
        <div class="form-row">
          <label>Ejecutor Nuevo:</label>
          <input v-model.number="reasignarForm.ejecutor_nuevo" type="number" required />
        </div>
        <div class="form-row">
          <label>Fecha de Reasignación:</label>
          <input v-model="reasignarForm.fecha" type="date" required />
        </div>
        <button type="submit">Confirmar Reasignación</button>
        <button type="button" @click="showReasignar=false">Cancelar</button>
      </form>
    </div>

    <div v-if="message" class="message">
      {{ message }}
    </div>
  </div>
</template>

<script>
export default {
  name: 'CancelacionRango',
  data() {
    return {
      form: {
        tipo: 'predial',
        recaud: '',
        folio_ini: '',
        folio_fin: ''
      },
      folios: [],
      seleccionados: [],
      showCancelar: false,
      showReasignar: false,
      cancelarForm: {
        motivo: '',
        usuario: ''
      },
      reasignarForm: {
        ejecutor_actual: '',
        ejecutor_nuevo: '',
        fecha: ''
      },
      message: ''
    }
  },
  methods: {
    async buscarFolios() {
      this.message = '';
      this.folios = [];
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          eRequest: {
            action: 'buscarFolios',
            params: this.form
          }
        })
      });
      const data = await res.json();
      if (data.eResponse.status === 'success') {
        this.folios = data.eResponse.data;
        this.seleccionados = [...this.folios];
      } else {
        this.message = data.eResponse.message;
      }
    },
    seleccionarFolio(folio) {
      if (!this.seleccionados.find(f => f.folioreq === folio.folioreq)) {
        this.seleccionados.push(folio);
      } else {
        this.seleccionados = this.seleccionados.filter(f => f.folioreq !== folio.folioreq);
      }
    },
    abrirCancelar() {
      this.showCancelar = true;
      this.showReasignar = false;
      this.cancelarForm.usuario = '';
      this.cancelarForm.motivo = '';
    },
    abrirReasignar() {
      this.showReasignar = true;
      this.showCancelar = false;
      this.reasignarForm.ejecutor_actual = '';
      this.reasignarForm.ejecutor_nuevo = '';
      this.reasignarForm.fecha = '';
    },
    async cancelarFolios() {
      this.message = '';
      const params = {
        tipo: this.form.tipo,
        folio_ini: Math.min(...this.seleccionados.map(f => f.folioreq)),
        folio_fin: Math.max(...this.seleccionados.map(f => f.folioreq)),
        recaud: this.form.recaud,
        usuario: this.cancelarForm.usuario,
        motivo: this.cancelarForm.motivo
      };
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          eRequest: {
            action: 'cancelarFolios',
            params
          }
        })
      });
      const data = await res.json();
      if (data.eResponse.status === 'success') {
        this.message = 'Folios cancelados correctamente';
        this.showCancelar = false;
        this.buscarFolios();
      } else {
        this.message = data.eResponse.message;
      }
    },
    async reasignarFolios() {
      this.message = '';
      const params = {
        tipo: this.form.tipo,
        folio_ini: Math.min(...this.seleccionados.map(f => f.folioreq)),
        folio_fin: Math.max(...this.seleccionados.map(f => f.folioreq)),
        recaud: this.form.recaud,
        ejecutor_actual: this.reasignarForm.ejecutor_actual,
        ejecutor_nuevo: this.reasignarForm.ejecutor_nuevo,
        fecha: this.reasignarForm.fecha
      };
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          eRequest: {
            action: 'reasignarFolios',
            params
          }
        })
      });
      const data = await res.json();
      if (data.eResponse.status === 'success') {
        this.message = 'Folios reasignados correctamente';
        this.showReasignar = false;
        this.buscarFolios();
      } else {
        this.message = data.eResponse.message;
      }
    }
  }
}
</script>

<style scoped>
.cancelacion-rango {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem;
}
.form-row {
  margin-bottom: 1rem;
  display: flex;
  align-items: center;
}
.form-row label {
  width: 180px;
  font-weight: bold;
}
.table {
  width: 100%;
  border-collapse: collapse;
  margin-top: 1rem;
}
.table th, .table td {
  border: 1px solid #ccc;
  padding: 0.5rem;
}
.actions {
  margin-top: 1rem;
}
.message {
  margin-top: 1rem;
  color: #007700;
  font-weight: bold;
}
</style>
