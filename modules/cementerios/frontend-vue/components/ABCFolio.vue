<template>
  <div class="abcf-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active">Modificación/Baja de Folio Cementerio</li>
      </ol>
    </nav>
    <div class="card">
      <div class="card-header bg-primary text-white">Modificación y Baja de Datos de Cementerios por Folio</div>
      <div class="card-body">
        <form @submit.prevent="onBuscar">
          <div class="row mb-3">
            <div class="col-md-3">
              <label for="folio">Folio</label>
              <input v-model="folio" type="number" class="form-control" id="folio" required />
            </div>
            <div class="col-md-2 align-self-end">
              <button type="submit" class="btn btn-success">Buscar</button>
            </div>
          </div>
        </form>
        <div v-if="error" class="alert alert-danger">{{ error }}</div>
        <div v-if="folioData">
          <form @submit.prevent="onGuardar">
            <div class="row">
              <div class="col-md-4">
                <label>Cementerio</label>
                <select v-model="form.cementerio" class="form-control" required>
                  <option v-for="cem in cementerios" :key="cem.cementerio" :value="cem.cementerio">{{ cem.nombre }}</option>
                </select>
              </div>
              <div class="col-md-2">
                <label>Clase</label>
                <input v-model="form.clase" type="number" class="form-control" required min="1" max="3" />
              </div>
              <div class="col-md-2">
                <label>Clase Alfa</label>
                <input v-model="form.clase_alfa" type="text" class="form-control" maxlength="10" />
              </div>
              <div class="col-md-2">
                <label>Sección</label>
                <input v-model="form.seccion" type="number" class="form-control" required min="1" />
              </div>
              <div class="col-md-2">
                <label>Sección Alfa</label>
                <input v-model="form.seccion_alfa" type="text" class="form-control" maxlength="10" />
              </div>
            </div>
            <div class="row mt-2">
              <div class="col-md-2">
                <label>Línea</label>
                <input v-model="form.linea" type="number" class="form-control" required min="1" />
              </div>
              <div class="col-md-2">
                <label>Línea Alfa</label>
                <input v-model="form.linea_alfa" type="text" class="form-control" maxlength="20" />
              </div>
              <div class="col-md-2">
                <label>Fosa</label>
                <input v-model="form.fosa" type="number" class="form-control" required min="1" />
              </div>
              <div class="col-md-2">
                <label>Fosa Alfa</label>
                <input v-model="form.fosa_alfa" type="text" class="form-control" maxlength="20" />
              </div>
              <div class="col-md-2">
                <label>UAP</label>
                <input v-model="form.axo_pagado" type="number" class="form-control" required min="1994" />
              </div>
              <div class="col-md-2">
                <label>Metros</label>
                <input v-model="form.metros" type="number" step="0.001" class="form-control" required min="0.5" />
              </div>
            </div>
            <div class="row mt-2">
              <div class="col-md-6">
                <label>Nombre</label>
                <input v-model="form.nombre" type="text" class="form-control" maxlength="60" required />
              </div>
              <div class="col-md-6">
                <label>Domicilio</label>
                <input v-model="form.domicilio" type="text" class="form-control" maxlength="60" required />
              </div>
            </div>
            <div class="row mt-2">
              <div class="col-md-2">
                <label>Exterior</label>
                <input v-model="form.exterior" type="text" class="form-control" maxlength="6" />
              </div>
              <div class="col-md-2">
                <label>Interior</label>
                <input v-model="form.interior" type="text" class="form-control" maxlength="6" />
              </div>
              <div class="col-md-4">
                <label>Colonia</label>
                <input v-model="form.colonia" type="text" class="form-control" maxlength="30" />
              </div>
              <div class="col-md-4">
                <label>Observaciones</label>
                <input v-model="form.observaciones" type="text" class="form-control" maxlength="60" />
              </div>
            </div>
            <div class="row mt-2">
              <div class="col-md-3">
                <label>Tipo</label>
                <select v-model="form.tipo" class="form-control" required>
                  <option value="F">Fosa</option>
                  <option value="U">Urna</option>
                  <option value="G">Gaveta</option>
                </select>
              </div>
              <div class="col-md-3">
                <label>Teléfono</label>
                <input v-model="form.adicional.telefono" type="text" class="form-control" maxlength="10" />
              </div>
              <div class="col-md-3">
                <label>RFC</label>
                <input v-model="form.adicional.rfc" type="text" class="form-control" maxlength="13" />
              </div>
              <div class="col-md-3">
                <label>CURP</label>
                <input v-model="form.adicional.curp" type="text" class="form-control" maxlength="18" />
              </div>
            </div>
            <div class="row mt-2">
              <div class="col-md-3">
                <label>Clave IFE</label>
                <input v-model="form.adicional.clave_ife" type="text" class="form-control" maxlength="18" />
              </div>
            </div>
            <div class="row mt-3">
              <div class="col-md-6">
                <button type="submit" class="btn btn-primary">Guardar Cambios</button>
                <button type="button" class="btn btn-danger ml-2" @click="onBorrar">Dar de Baja</button>
              </div>
            </div>
          </form>
          <div class="mt-4">
            <h5>Adeudos Vigentes</h5>
            <table class="table table-sm table-bordered">
              <thead>
                <tr>
                  <th>Año</th>
                  <th>Importe</th>
                  <th>Recargos</th>
                  <th>Descto Importe</th>
                  <th>Descto Recargos</th>
                  <th>Actualización</th>
                  <th>Usuario</th>
                  <th>Fecha Mov</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="a in adeudos" :key="a.id_adeudo">
                  <td>{{ a.axo_adeudo }}</td>
                  <td>{{ a.importe }}</td>
                  <td>{{ a.importe_recargos }}</td>
                  <td>{{ a.descto_impote }}</td>
                  <td>{{ a.descto_recargos }}</td>
                  <td>{{ a.actualizacion }}</td>
                  <td>{{ a.usuario }}</td>
                  <td>{{ a.fecha_mov }}</td>
                </tr>
                <tr v-if="adeudos.length === 0"><td colspan="8">Sin adeudos vigentes</td></tr>
              </tbody>
            </table>
          </div>
        </div>
        <div v-if="success" class="alert alert-success mt-3">{{ success }}</div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'ABCFolioPage',
  data() {
    return {
      folio: '',
      folioData: null,
      form: {},
      cementerios: [],
      adeudos: [],
      error: '',
      success: ''
    };
  },
  created() {
    this.fetchCementerios();
  },
  methods: {
    async fetchCementerios() {
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action: 'getCementerios' })
      });
      const json = await res.json();
      if (json.success) {
        this.cementerios = json.data;
      }
    },
    async onBuscar() {
      this.error = '';
      this.success = '';
      this.folioData = null;
      this.adeudos = [];
      if (!this.folio) return;
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action: 'getFolio', data: { folio: this.folio } })
      });
      const json = await res.json();
      if (json.success && json.data.folio) {
        this.folioData = json.data.folio;
        this.adeudos = json.data.adeudos;
        this.form = {
          ...json.data.folio,
          adicional: json.data.adicional || { telefono: '', rfc: '', curp: '', clave_ife: '' }
        };
      } else {
        this.error = json.message || 'Folio no encontrado';
      }
    },
    async onGuardar() {
      this.error = '';
      this.success = '';
      const payload = { ...this.form, control_rcm: this.folio };
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action: 'updateFolio', data: payload })
      });
      const json = await res.json();
      if (json.success) {
        this.success = json.message;
        await this.onBuscar();
      } else {
        this.error = json.message || 'Error al guardar';
      }
    },
    async onBorrar() {
      if (!confirm('¿Está seguro de dar de baja este folio?')) return;
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action: 'deleteFolio', data: { control_rcm: this.folio } })
      });
      const json = await res.json();
      if (json.success) {
        this.success = json.message;
        this.folioData = null;
        this.form = {};
        this.adeudos = [];
      } else {
        this.error = json.message || 'Error al dar de baja';
      }
    }
  }
};
</script>

<style scoped>
.abcf-page {
  max-width: 900px;
  margin: 0 auto;
}
.card {
  box-shadow: 0 2px 8px rgba(0,0,0,0.08);
}
</style>
