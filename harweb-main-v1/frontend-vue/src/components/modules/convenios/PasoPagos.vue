<template>
  <div class="paso-pagos-page">
    <h1>Carga de Pagos de AS/400 a Tabla de Paso</h1>
    <div class="breadcrumb">
      <router-link to="/">Inicio</router-link> / PasoPagos
    </div>
    <div class="form-section">
      <div class="radio-group">
        <label><input type="radio" v-model="tipo" value="contrato"> Contratos D.S.</label>
        <label><input type="radio" v-model="tipo" value="convenio"> Convenios Gral.</label>
      </div>
      <div v-if="tipo === 'contrato'">
        <h2>Pagos Contratos D.S.</h2>
        <input type="file" @change="onFileChange($event, 'contrato')">
        <button @click="procesarArchivo('contrato')">Procesar Archivo</button>
        <button @click="guardarPagos('contrato')" :disabled="contratoRows.length === 0">Grabar</button>
        <table v-if="contratoRows.length">
          <thead>
            <tr>
              <th v-for="col in contratoCols" :key="col">{{ col }}</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="row in contratoRows" :key="row.control">
              <td v-for="col in contratoCols" :key="col">{{ row[col] }}</td>
            </tr>
          </tbody>
        </table>
        <div v-if="contratoStatus">
          <p class="status" :class="{error: !contratoStatus.success}">{{ contratoStatus.message }}</p>
        </div>
      </div>
      <div v-if="tipo === 'convenio'">
        <h2>Pagos Convenios Generales</h2>
        <input type="file" @change="onFileChange($event, 'convenio')">
        <button @click="procesarArchivo('convenio')">Procesar Archivo</button>
        <button @click="guardarPagos('convenio')" :disabled="convenioRows.length === 0">Grabar</button>
        <table v-if="convenioRows.length">
          <thead>
            <tr>
              <th v-for="col in convenioCols" :key="col">{{ col }}</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="row in convenioRows" :key="row.control">
              <td v-for="col in convenioCols" :key="col">{{ row[col] }}</td>
            </tr>
          </tbody>
        </table>
        <div v-if="convenioStatus">
          <p class="status" :class="{error: !convenioStatus.success}">{{ convenioStatus.message }}</p>
        </div>
      </div>
    </div>
    <div class="status-section">
      <button @click="consultarStatus">Consultar Estatus DS</button>
      <div v-if="dsStatus">
        <p>Grabados: {{ dsStatus.expression }}</p>
        <p>Modificados: {{ dsStatus.expression_1 }}</p>
        <p>Inconsistentes: {{ dsStatus.inconsistentes }}</p>
        <p>Total: {{ dsStatus.total }}</p>
      </div>
    </div>
    <div class="actions">
      <router-link to="/" class="btn">Salir</router-link>
    </div>
  </div>
</template>

<script>
export default {
  name: 'PasoPagosPage',
  data() {
    return {
      tipo: 'contrato',
      contratoFile: null,
      convenioFile: null,
      contratoRows: [],
      convenioRows: [],
      contratoCols: ['control','colonia','calle','folio','fecha','oficina','caja','operacion','pago_parcial','total_parciales','importe','desc','bonif','usuario','fecha_actual'],
      convenioCols: ['control','tipo','subtipo','manzana','lote','letra','fecha','rec','caja','oper','pag_parc','tot_parc','imp_pago','desc','bonif','usuario','actual','imp_rec','cve_venc'],
      contratoStatus: null,
      convenioStatus: null,
      dsStatus: null
    }
  },
  methods: {
    onFileChange(e, tipo) {
      const file = e.target.files[0];
      if (!file) return;
      const reader = new FileReader();
      reader.onload = (evt) => {
        if (tipo === 'contrato') {
          this.contratoFile = { content: evt.target.result, name: file.name };
        } else {
          this.convenioFile = { content: evt.target.result, name: file.name };
        }
      };
      reader.readAsDataURL(file);
    },
    async procesarArchivo(tipo) {
      let fileObj = tipo === 'contrato' ? this.contratoFile : this.convenioFile;
      if (!fileObj) return alert('Seleccione un archivo');
      // Extraer base64 puro
      let base64 = fileObj.content.split(',')[1];
      let action = tipo === 'contrato' ? 'openContrato' : 'openConvenio';
      let res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          eRequest: {
            action,
            payload: { file: base64, filename: fileObj.name }
          }
        })
      });
      let json = await res.json();
      if (json.eResponse.success) {
        if (tipo === 'contrato') {
          this.contratoRows = json.eResponse.data;
          this.contratoStatus = { success: true, message: 'Archivo procesado' };
        } else {
          this.convenioRows = json.eResponse.data;
          this.convenioStatus = { success: true, message: 'Archivo procesado' };
        }
      } else {
        if (tipo === 'contrato') {
          this.contratoStatus = { success: false, message: json.eResponse.message };
        } else {
          this.convenioStatus = { success: false, message: json.eResponse.message };
        }
      }
    },
    async guardarPagos(tipo) {
      let rows = tipo === 'contrato' ? this.contratoRows : this.convenioRows;
      let action = tipo === 'contrato' ? 'saveContrato' : 'saveConvenio';
      let res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          eRequest: {
            action,
            payload: { rows }
          }
        })
      });
      let json = await res.json();
      if (json.eResponse.success) {
        if (tipo === 'contrato') {
          this.contratoStatus = { success: true, message: json.eResponse.message };
        } else {
          this.convenioStatus = { success: true, message: json.eResponse.message };
        }
      } else {
        if (tipo === 'contrato') {
          this.contratoStatus = { success: false, message: json.eResponse.message };
        } else {
          this.convenioStatus = { success: false, message: json.eResponse.message };
        }
      }
    },
    async consultarStatus() {
      let id_usuario = 1; // Debe obtenerse del login/session
      let res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          eRequest: {
            action: 'statusDS',
            payload: { id_usuario }
          }
        })
      });
      let json = await res.json();
      if (json.eResponse.success) {
        let data = json.eResponse.data;
        this.dsStatus = {
          expression: data.expression,
          expression_1: data.expression_1,
          inconsistentes: (this.contratoRows.length || 0) - (data.expression + data.expression_1),
          total: this.contratoRows.length || 0
        };
      } else {
        this.dsStatus = null;
        alert(json.eResponse.message);
      }
    }
  }
}
</script>

<style scoped>
.paso-pagos-page { max-width: 1200px; margin: 0 auto; padding: 2rem; }
.breadcrumb { margin-bottom: 1rem; color: #888; }
.form-section { margin-bottom: 2rem; }
.radio-group { margin-bottom: 1rem; }
table { border-collapse: collapse; width: 100%; margin-top: 1rem; }
th, td { border: 1px solid #ccc; padding: 0.3rem 0.5rem; }
.status { margin-top: 1rem; }
.status.error { color: red; }
.status-section { margin-top: 2rem; }
.actions { margin-top: 2rem; }
.btn { background: #eee; padding: 0.5rem 1rem; border-radius: 4px; text-decoration: none; }
</style>
