<template>
  <div class="modlic-adeudo-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Adeudo de Licencia</li>
      </ol>
    </nav>
    <div class="card">
      <div class="card-header">
        <strong>Adeudo de la licencia</strong>
      </div>
      <div class="card-body">
        <div class="mb-2">
          <button class="btn btn-primary btn-sm me-2" @click="onAgregar" :disabled="formVisible">Agregar</button>
          <button class="btn btn-secondary btn-sm me-2" @click="onModificar" :disabled="!selectedRow || formVisible">Modificar</button>
          <button class="btn btn-danger btn-sm me-2" @click="onEliminar" :disabled="!selectedRow || formVisible">Eliminar</button>
          <button class="btn btn-success btn-sm me-2" @click="onAceptar" v-if="formVisible">Aceptar</button>
          <button class="btn btn-warning btn-sm me-2" @click="onCancelar" v-if="formVisible">Cancelar</button>
          <router-link class="btn btn-outline-secondary btn-sm" to="/">Regresar</router-link>
        </div>
        <div v-if="formVisible" class="mb-3">
          <form @submit.prevent="onAceptar">
            <div class="row g-2 align-items-center">
              <div class="col-auto">
                <label for="axo" class="col-form-label">Año</label>
                <input type="number" min="1900" class="form-control form-control-sm" v-model.number="form.axo" required />
              </div>
              <div class="col-auto">
                <label for="derechos" class="col-form-label">Derechos</label>
                <input type="number" step="0.01" class="form-control form-control-sm" v-model.number="form.derechos" required />
              </div>
              <div class="col-auto">
                <label for="derechos2" class="col-form-label">Derechos2 10%</label>
                <input type="number" step="0.01" class="form-control form-control-sm" v-model.number="form.derechos2" />
              </div>
              <div class="col-auto">
                <label for="forma" class="col-form-label">Forma</label>
                <input type="number" step="0.01" class="form-control form-control-sm" v-model.number="form.forma" required />
              </div>
            </div>
          </form>
        </div>
        <table class="table table-sm table-bordered table-hover">
          <thead>
            <tr>
              <th>Año</th>
              <th>Derechos</th>
              <th>Derechos2</th>
              <th>Forma</th>
              <th>Recargos</th>
              <th>Saldo</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="row in adeudos" :key="row.id" :class="{ 'table-active': selectedRow && selectedRow.id === row.id }" @click="selectRow(row)">
              <td>{{ row.axo }}</td>
              <td>{{ row.derechos }}</td>
              <td>{{ row.derechos2 }}</td>
              <td>{{ row.forma }}</td>
              <td>{{ row.recargos }}</td>
              <td>{{ row.saldo }}</td>
            </tr>
            <tr v-if="adeudos.length === 0">
              <td colspan="6" class="text-center">No hay registros</td>
            </tr>
          </tbody>
        </table>
        <div class="mt-3">
          <h6>Saldos de Licencia</h6>
          <div v-if="saldosLic">
            <ul>
              <li><strong>Derechos:</strong> {{ saldosLic.derechos }}</li>
              <li><strong>Anuncios:</strong> {{ saldosLic.anuncios }}</li>
              <li><strong>Recargos:</strong> {{ saldosLic.recargos }}</li>
              <li><strong>Gastos:</strong> {{ saldosLic.gastos }}</li>
              <li><strong>Multas:</strong> {{ saldosLic.multas }}</li>
              <li><strong>Formas:</strong> {{ saldosLic.formas }}</li>
              <li><strong>Total:</strong> {{ saldosLic.total }}</li>
              <li><strong>Base:</strong> {{ saldosLic.base }}</li>
              <li><strong>Desc. Derechos:</strong> {{ saldosLic.desc_derechos }}</li>
              <li><strong>Desc. Recargos:</strong> {{ saldosLic.desc_recargos }}</li>
            </ul>
          </div>
          <div v-else>
            <em>No hay información de saldos</em>
          </div>
        </div>
      </div>
    </div>
    <div v-if="errorMessage" class="alert alert-danger mt-3">{{ errorMessage }}</div>
  </div>
</template>

<script>
export default {
  name: 'ModlicAdeudoPage',
  props: {
    idLicencia: { type: [String, Number], required: true },
    idAnuncio: { type: [String, Number], required: true }
  },
  data() {
    return {
      adeudos: [],
      selectedRow: null,
      formVisible: false,
      form: {
        id: null,
        axo: '',
        derechos: 0,
        derechos2: 0,
        forma: 0
      },
      saldosLic: null,
      errorMessage: ''
    };
  },
  mounted() {
    this.loadAdeudos();
    this.loadSaldosLic();
  },
  methods: {
    async apiRequest(action, data = {}) {
      try {
        const res = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ eRequest: { action, data } })
        });
        const json = await res.json();
        if (!json.eResponse.success) throw new Error(json.eResponse.message);
        return json.eResponse.data;
      } catch (e) {
        this.errorMessage = e.message;
        throw e;
      }
    },
    async loadAdeudos() {
      this.errorMessage = '';
      try {
        this.adeudos = await this.apiRequest('list', {
          id_licencia: this.idLicencia,
          id_anuncio: this.idAnuncio
        });
        this.selectedRow = null;
      } catch {}
    },
    async loadSaldosLic() {
      this.errorMessage = '';
      try {
        const saldos = await this.apiRequest('get_saldos', { id_licencia: this.idLicencia });
        this.saldosLic = saldos && saldos.length ? saldos[0] : null;
      } catch {}
    },
    selectRow(row) {
      if (this.formVisible) return;
      this.selectedRow = row;
    },
    onAgregar() {
      this.form = {
        id: null,
        axo: '',
        derechos: 0,
        derechos2: 0,
        forma: 0
      };
      this.formVisible = true;
      this.selectedRow = null;
    },
    onModificar() {
      if (!this.selectedRow) return;
      this.form = {
        id: this.selectedRow.id,
        axo: this.selectedRow.axo,
        derechos: this.selectedRow.derechos,
        derechos2: this.selectedRow.derechos2,
        forma: this.selectedRow.forma
      };
      this.formVisible = true;
    },
    async onAceptar() {
      this.errorMessage = '';
      try {
        if (!this.form.axo || !this.form.derechos || !this.form.forma) {
          this.errorMessage = 'Todos los campos requeridos deben ser llenados';
          return;
        }
        if (this.form.id) {
          // Editar
          await this.apiRequest('edit', {
            id: this.form.id,
            id_licencia: this.idLicencia,
            id_anuncio: this.idAnuncio,
            axo: this.form.axo,
            derechos: this.form.derechos,
            derechos2: this.form.derechos2,
            forma: this.form.forma
          });
        } else {
          // Agregar
          await this.apiRequest('add', {
            id_licencia: this.idLicencia,
            id_anuncio: this.idAnuncio,
            axo: this.form.axo,
            derechos: this.form.derechos,
            derechos2: this.form.derechos2,
            forma: this.form.forma
          });
        }
        this.formVisible = false;
        await this.loadAdeudos();
        await this.loadSaldosLic();
      } catch {}
    },
    onCancelar() {
      this.formVisible = false;
      this.errorMessage = '';
    },
    async onEliminar() {
      if (!this.selectedRow) return;
      if (!confirm('¿Seguro(a) que desea eliminar el adeudo?')) return;
      try {
        await this.apiRequest('delete', {
          id: this.selectedRow.id,
          id_licencia: this.idLicencia
        });
        await this.loadAdeudos();
        await this.loadSaldosLic();
      } catch {}
    }
  }
};
</script>

<style scoped>
.modlic-adeudo-page {
  max-width: 900px;
  margin: 0 auto;
}
.table-active {
  background-color: #e9ecef;
}
</style>
